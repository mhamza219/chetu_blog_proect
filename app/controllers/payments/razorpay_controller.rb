module Payments
  class RazorpayController < ApplicationController
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
          stripe_id: "pay_" + SecureRandom.hex(7), # Mock Razorpay payment ID
          amount: (@order.total * 100).to_i,
          status: 'success',
          last4: params[:payment_method] == 'card' ? '1111' : nil,
          card_brand: params[:payment_method] == 'card' ? 'Visa' : (params[:payment_method] || 'UPI')
        )
        @order.update!(status: 'paid')
      end

      redirect_to success_path(order_id: @order.id), notice: "Payment successfully processed through Razorpay!"
    end

    def cancel
      @order = Order.find(params[:order_id])
      redirect_to cancel_path(order_id: @order.id), alert: "Razorpay payment was cancelled."
    end
  end
end
