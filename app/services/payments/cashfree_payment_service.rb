module Payments
  class CashfreePaymentService
    def initialize(order)
      @order = order
    end

    def create_checkout_session
      # Mock session setup for Cashfree sandbox simulation
      Struct.new(:id, :url).new(
        "cf_sess_" + SecureRandom.hex(6),
        Rails.application.routes.url_helpers.cashfree_checkout_path(order_id: @order.id)
      )
    end
  end
end
