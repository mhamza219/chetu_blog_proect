class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    # Fetch orders for the logged-in user, newest first
    @orders = Order.where(user_id: current_user.id).includes(:transactions).order(created_at: :desc)
  end

  def show
    @order = Order.find_by!(id: params[:id], user_id: current_user.id)
    @line_items = @order.line_items.includes(:product)
    @transaction = @order.transactions.last
  end
end