class PaymentStatusPageController < ApplicationController
  def success
    session[:cart_id] = nil
    @order = Order.find_by(id: params[:order_id]) || Order.find_by(stripe_checkout_id: params[:session_id])
  end

  def cancel
    @order = Order.find_by(id: params[:order_id]) || Order.find_by(stripe_checkout_id: params[:session_id])
    if @order
      @order.update(status: 'canceled')
    end
  end
end