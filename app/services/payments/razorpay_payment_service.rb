module Payments
  class RazorpayPaymentService
    def initialize(order)
      @order = order
    end

    def create_checkout_session
      # Mock session setup for Razorpay sandbox simulation
      Struct.new(:id, :url).new(
        "rzp_sess_" + SecureRandom.hex(6),
        Rails.application.routes.url_helpers.razorpay_checkout_path(order_id: @order.id)
      )
    end
  end
end
