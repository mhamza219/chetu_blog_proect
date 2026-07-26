class DistanceCalculatorController < ApplicationController
  def index
    # Pre-fill origin coordinates from current_user if logged in and location set
    if user_signed_in? && current_user.latitude.present? && current_user.longitude.present?
      @default_origin_lat = current_user.latitude
      @default_origin_lng = current_user.longitude
      @default_origin_name = current_user.formatted_location
    else
      # Default fallback coordinates (e.g. San Francisco or London if none provided)
      @default_origin_lat = 37.7749
      @default_origin_lng = -122.4194
      @default_origin_name = "San Francisco, CA"
    end
  end

  def calculate
    origin_query = params[:origin].to_s.strip
    destination_query = params[:destination].to_s.strip

    origin_coords = parse_location(origin_query, params[:origin_lat], params[:origin_lng])
    dest_coords = parse_location(destination_query, params[:dest_lat], params[:dest_lng])

    if origin_coords.nil?
      render json: { status: "error", message: "Could not find location for origin: '#{origin_query}'" }, status: :unprocessable_entity
      return
    end

    if dest_coords.nil?
      render json: { status: "error", message: "Could not find location for destination: '#{destination_query}'" }, status: :unprocessable_entity
      return
    end

    # Calculate distance using Geocoder
    dist_km = Geocoder::Calculations.distance_between(origin_coords, dest_coords, units: :km).round(2)
    dist_miles = Geocoder::Calculations.distance_between(origin_coords, dest_coords, units: :mi).round(2)
    bearing = Geocoder::Calculations.bearing_between(origin_coords, dest_coords).round(1)
    compass_point = Geocoder::Calculations.compass_point(bearing)

    # Reverse geocode names if not provided
    origin_name = resolve_name(origin_coords, origin_query)
    dest_name = resolve_name(dest_coords, destination_query)

    render json: {
      status: "success",
      origin: {
        latitude: origin_coords[0],
        longitude: origin_coords[1],
        name: origin_name
      },
      destination: {
        latitude: dest_coords[0],
        longitude: dest_coords[1],
        name: dest_name
      },
      distance_km: dist_km,
      distance_miles: dist_miles,
      bearing: bearing,
      compass_point: compass_point
    }
  end

  def search
    query = params[:q].to_s.strip
    if query.present?
      results = Geocoder.search(query)
      mapped_results = results.map do |res|
        {
          name: res.address,
          latitude: res.latitude,
          longitude: res.longitude,
          city: res.city,
          country: res.country
        }
      end
      render json: { status: "success", results: mapped_results }
    else
      render json: { status: "success", results: [] }
    end
  end

  private

  def parse_location(query, lat, lng)
    if lat.present? && lng.present? && lat.to_f != 0.0 && lng.to_f != 0.0
      [lat.to_f, lng.to_f]
    elsif query.present?
      geo = Geocoder.search(query).first
      geo ? [geo.latitude, geo.longitude] : nil
    else
      nil
    end
  end

  def resolve_name(coords, query)
    return query if query.present? && !query.match?(/^-?\d+(\.\d+)?, -?\d+(\.\d+)?$/)

    geo = Geocoder.search(coords).first
    if geo
      [geo.city, geo.state, geo.country].compact.reject(&:blank?).join(', ').presence || geo.address
    else
      "#{coords[0].round(4)}°, #{coords[1].round(4)}°"
    end
  end
end
