class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Add this only for one refresh to clear browser brains
  before_action :clear_hsts_locally

  def clear_hsts_locally
    response.headers['Strict-Transport-Security'] = 'max-age=0'
  end
end
