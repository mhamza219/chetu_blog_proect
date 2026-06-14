module Payments
  class CashfreeController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:success, :cancel]

    def checkout
      @order = Order.find(params[:order_id])
      unless @order.user_id == current_user.id.to_s
        redirect_to root_path, alert: "Access denied."
        return
      end
    end

    def success
      @order = Order.find(params[:order_id])
      
      ActiveRecord::Base.transaction do
        # Create a mock transaction
        Transaction.create!(
          order_id: @order.id.to_s,
          stripe_id: "cf_pay_" + SecureRandom.hex(6), # Mock Cashfree payment ID
          amount: (@order.total * 100).to_i, # Stored in cents
          status: 'success',
          last4: params[:payment_method] == 'card' ? '1111' : nil,
          card_brand: params[:payment_method] == 'card' ? 'RuPay' : (params[:payment_method] || 'UPI')
        )

        @order.update!(status: 'paid')
      end

      redirect_to success_path(order_id: @order.id), notice: "Payment successfully processed through Cashfree!"
    end

    def cancel
      @order = Order.find(params[:order_id])
      redirect_to cancel_path(order_id: @order.id), alert: "Cashfree payment was cancelled."
    end
  end
end
