class CheckoutsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_not_empty, only: [:show, :create]

  def show
    @user = current_user
  end

  def create
    # 1. Create the pending order
    @order = Order.create!(
      user_id: current_user.id.to_s,
      total: @cart.total_price,
      status: 'pending'
    )

    # 2. Transfer line items from cart to order
    @cart.line_items.update_all(order_id: @order.id, cart_id: nil)
    @order.reload

    # 3. Route based on gateway selection
    case params[:payment_gateway]
    when 'stripe'
      redirect_to stripe_checkout_path(order_id: @order.id)
    when 'cashfree'
      redirect_to cashfree_checkout_path(order_id: @order.id)
    when 'razorpay'
      redirect_to razorpay_checkout_path(order_id: @order.id)
    when 'billdesk'
      redirect_to billdesk_checkout_path(order_id: @order.id)
    else
      redirect_to checkout_path, alert: "Invalid payment gateway selected."
    end
  end

  private

  def ensure_cart_not_empty
    @cart = current_cart
    if @cart.line_items.empty?
      redirect_to root_path, alert: "Your cart is empty!"
    end
  end
end
