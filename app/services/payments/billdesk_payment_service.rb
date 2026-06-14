module Payments
  class BilldeskPaymentService
    def initialize(order)
      @order = order
    end

    def create_checkout_session
      # Mock session setup for Billdesk sandbox simulation
      Struct.new(:id, :url).new(
        "bd_sess_" + SecureRandom.hex(6),
        Rails.application.routes.url_helpers.billdesk_checkout_path(order_id: @order.id)
      )
    end
  end
end
