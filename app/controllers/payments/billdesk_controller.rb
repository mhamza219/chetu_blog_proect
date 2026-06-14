module Payments
  class BilldeskController < ApplicationController
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
      unless @order.user_id == current_user.id.to_s
        redirect_to root_path, alert: "Access denied."
        return
      end

      ActiveRecord::Base.transaction do
        Transaction.create!(
          order_id: @order.id.to_s,
          stripe_id: "bd_pay_" + SecureRandom.hex(7), # Mock Billdesk payment ID
          amount: (@order.total * 100).to_i,
          status: 'success',
          last4: params[:payment_method] == 'card' ? '1111' : nil,
          card_brand: params[:payment_method] == 'card' ? 'RuPay' : (params[:payment_method] || 'Netbanking')
        )
        @order.update!(status: 'paid')
      end

      redirect_to success_path(order_id: @order.id), notice: "Payment successfully processed through BillDesk!"
    end

    def cancel
      @order = Order.find(params[:order_id])
      redirect_to cancel_path(order_id: @order.id), alert: "BillDesk payment was cancelled."
    end
  end
end
