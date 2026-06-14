module Payments
  class StripePaymentService
    def initialize(order)
      @order = order
      if ENV['STRIPE_SECRET_KEY'].present?
        Stripe.api_key = ENV['STRIPE_SECRET_KEY']
      end
    end

    def create_checkout_session(success_url, cancel_url)
      if ENV['STRIPE_SECRET_KEY'].present?
        Stripe::Checkout::Session.create({
          customer_email: @order.user.email,
          payment_method_types: ['card'],
          line_items: build_line_items,
          mode: 'payment',
          metadata: { order_id: @order.id },
          success_url: success_url,
          cancel_url: cancel_url
        })
      else
        Struct.new(:id, :url).new(
          "mock_stripe_sess_" + SecureRandom.hex(6),
          Rails.application.routes.url_helpers.stripe_checkout_mock_path(order_id: @order.id)
        )
      end
    end

    private

    def build_line_items
      @order.line_items.map do |item|
        {
          price_data: {
            currency: 'usd',
            unit_amount: item.product.price, # From your schema
            product_data: { 
              name: item.product.title,      # From your schema 'title'
              description: item.product.description 
            },
          },
          quantity: item.quantity,
        }
      end
    end
  end
end