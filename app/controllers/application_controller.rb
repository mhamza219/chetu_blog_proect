class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Add this only for one refresh to clear browser brains
  before_action :clear_hsts_locally

  before_action :set_cart
  helper_method :current_cart

  def clear_hsts_locally
    response.headers['Strict-Transport-Security'] = 'max-age=0'
  end

  private

  def set_cart
    if user_signed_in?
      # For logged-in users, you might eventually want to link cart to user.
      # For now, we stick to session-based.
      @cart = Cart.find_by(id: session[:cart_id]) || Cart.create
      session[:cart_id] ||= @cart.id
    else
      @cart = Cart.find_by(id: session[:cart_id]) || Cart.create
      session[:cart_id] ||= @cart.id
    end
  end

  def current_cart
    @cart ||= Cart.find_by(id: session[:cart_id]) || Cart.create
    session[:cart_id] ||= @cart.id
    @cart
  end
end
