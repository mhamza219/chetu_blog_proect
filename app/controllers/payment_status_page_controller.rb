class PaymentStatusPageController < ApplicationController
  def success
    # Payment was successful, so we clear the cart from the session
    session[:cart_id] = nil
    
    # Optionally retrieve the order to show details
    @session_id = params[:session_id]
    @order = Order.find_by(stripe_checkout_id: @session_id)
  end

  def cancel
    @order = Order.find_by(stripe_checkout_id: params[:session_id])
    if @order
      @order.update(status: 'canceled')
    end
  end
end