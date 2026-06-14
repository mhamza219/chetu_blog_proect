module Payments
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:webhook, :checkout_mock_success]

    def checkout
      @order = Order.find(params[:order_id])
      unless @order.user_id == current_user.id.to_s
        redirect_to root_path, alert: "Access denied."
        return
      end

      service = Payments::StripePaymentService.new(@order)
      
      begin
        @session = service.create_checkout_session(
          success_url(order_id: @order.id),
          cancel_url(order_id: @order.id)
        )
        @order.update(stripe_checkout_id: @session.id)
        redirect_to @session.url, allow_other_host: true
      rescue Stripe::InvalidRequestError => e
        redirect_to checkout_path, alert: "Stripe Error: #{e.message}"
      end
    end

    def checkout_mock
      @order = Order.find(params[:order_id])
      unless @order.user_id == current_user.id.to_s
        redirect_to root_path, alert: "Access denied."
        return
      end
    end

    def checkout_mock_success
      @order = Order.find(params[:order_id])
      unless @order.user_id == current_user.id.to_s
        redirect_to root_path, alert: "Access denied."
        return
      end

      ActiveRecord::Base.transaction do
        Transaction.create!(
          order_id: @order.id.to_s,
          stripe_id: "mock_stripe_tx_" + SecureRandom.hex(6),
          amount: (@order.total * 100).to_i,
          status: 'success',
          last4: '4242',
          card_brand: 'Visa'
        )
        @order.update!(status: 'paid')
      end

      redirect_to success_url(order_id: @order.id), notice: "Stripe sandbox payment successfully simulated!"
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