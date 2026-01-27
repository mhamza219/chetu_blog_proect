class CartsController < ApplicationController
  def show
    # @cart is already set by ApplicationController
  end

  def add_item
    # Convert product_id to string immediately to match your schema
    product_id_str = params[:product_id].to_s
    @product = Product.find(product_id_str)
    
    # Find or init using the string ID
    @line_item = @cart.line_items.find_or_initialize_by(product_id: product_id_str)
    
    @line_item.quantity ||= 0
    @line_item.quantity += 1
    
    # Check if cart_id is being set correctly as a string
    @line_item.cart_id = @cart.id.to_s

    if @line_item.save
      redirect_to cart_path, notice: "#{@product.title} added to cart."
    else
      # This will print the error to your 'rails s' terminal
      Rails.logger.error(@line_item.errors.full_messages)
      redirect_to products_path, alert: "Error: #{@line_item.errors.full_messages.join(', ')}"
    end
  end
end