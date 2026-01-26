module Payments
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:webhook]

    def checkout
      # @cart = Cart.find(params[:cart_id])
      @cart = current_cart
      
      if @cart.line_items.empty?
        redirect_to root_path, alert: "Your cart is empty!"
        return
      end

      # 1. Create the order
      @order = Order.create!(
        user_id: current_user.id,
        total: @cart.line_items.to_a.sum(&:total_price),
        status: 'pending'
      )
      
      # 2. Update line items to point to the order and remove them from the cart
      # We use .update_all to change the foreign keys in the database
      @cart.line_items.update_all(order_id: @order.id, cart_id: nil)

      # 3. CRITICAL: Reload the order so it "sees" the newly attached line_items
      @order.reload 

      # 4. Call Service
      service = Payments::StripePaymentService.new(@order)
      
      begin
        @session = service.create_checkout_session(success_url, cancel_url)
        @order.update(stripe_checkout_id: @session.id)
        redirect_to @session.url, allow_other_host: true
      rescue Stripe::InvalidRequestError => e
        redirect_to cart_path, alert: "Stripe Error: #{e.message}"
      end
    end

    def webhook
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = nil

      begin
        event = ::Stripe::Webhook.construct_event(
          payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET']
        )
      rescue JSON::ParserError, ::Stripe::SignatureVerificationError => e
        puts "⚠️ Webhook Signature Error: #{e.message}"
        return head :bad_request
      end

      if event.type == 'checkout.session.completed'
        session = event.data.object
        handle_success(session)
      end

      head :ok
    end

    private

    def handle_success(session)
      # Log exactly what metadata Stripe sent back
      order_id = session.metadata&.order_id
      Rails.logger.info "--- WEBHOOK START ---"
      Rails.logger.info "Metadata Order ID: #{order_id}"

      # Use to_s just in case the metadata is coming back as an object
      order = Order.find_by(id: order_id.to_s)
      
      if order
        Rails.logger.info "Order found: #{order.id}. Current status: #{order.status}"
        
        ActiveRecord::Base.transaction do
          # 1. Attempt to extract card info safely
          # Stripe objects can be tricky; if this fails, we fall back to defaults
          begin
            card_data = session.payment_method_options&.card
            last4 = card_data.respond_to?(:last4) ? card_data.last4 : "4242"
            brand = card_data.respond_to?(:network) ? card_data.network : "visa"
          rescue
            last4 = "4242"
            brand = "visa"
          end

          # 2. Create the transaction record
          Transaction.create!(
            order_id: order.id.to_s, 
            stripe_id: session.payment_intent,
            amount: session.amount_total,
            status: 'success',
            last4: last4,
            card_brand: brand
          )
          
          # 3. Update the order status
          order.update!(status: 'paid')
        end
        Rails.logger.info "SUCCESS: Order #{order.id} status updated to PAID."
      else
        Rails.logger.error "ERROR: Order with ID #{order_id} NOT FOUND in database."
        # List all pending orders to compare IDs in the log
        Rails.logger.info "Pending Order IDs: #{Order.where(status: 'pending').pluck(:id)}"
      end
      Rails.logger.info "--- WEBHOOK END ---"
    end

  end
end