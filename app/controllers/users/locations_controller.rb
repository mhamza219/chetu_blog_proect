class Users::LocationsController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  def update
    latitude = params[:latitude].presence&.to_f
    longitude = params[:longitude].presence&.to_f

    if latitude && longitude
      current_user.assign_attributes(latitude: latitude, longitude: longitude)
      
      # Try reverse geocoding directly if needed
      if current_user.save
        render json: {
          status: 'success',
          latitude: current_user.latitude,
          longitude: current_user.longitude,
          location: current_user.formatted_location
        }
      else
        render json: { status: 'error', errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { status: 'error', message: 'Invalid coordinates provided' }, status: :bad_request
    end
  end
end
