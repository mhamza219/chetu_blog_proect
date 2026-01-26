module Payments
  class StripePaymentService
    def initialize(order)
      @order = order
      Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    end

    def create_checkout_session(success_url, cancel_url)
      Stripe::Checkout::Session.create({
        customer_email: @order.user.email,
        payment_method_types: ['card'],
        line_items: build_line_items,
        mode: 'payment',
        metadata: { order_id: @order.id },
        success_url: success_url,
        cancel_url: cancel_url
      })
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