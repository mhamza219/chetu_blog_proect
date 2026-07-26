class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :blogs

  has_many :messages
  has_many :participants
  has_many :rooms, through: :participants

  has_one_attached :avatar

  # Geocoder setup
  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      city_state_country = [geo.city, geo.state, geo.country].compact.reject(&:blank?).join(', ')
      obj.location_name = city_state_country.presence || geo.address
    end
  end

  after_validation :reverse_geocode, if: ->(obj) { (obj.latitude_changed? || obj.longitude_changed?) && obj.latitude.present? && obj.longitude.present? }
  after_validation :geocode, if: ->(obj) { obj.address_changed? && obj.address.present? && !obj.latitude_changed? }

  def formatted_location
    location_name.presence || address.presence || (latitude.present? && longitude.present? ? "#{latitude.round(3)}°, #{longitude.round(3)}°" : nil)
  end

  def self.ransackable_attributes(auth_object = nil)
    # %w[id email created_at updated_at]
    column_names
  end

  def self.ransackable_associations(auth_object = nil)
    %w[blogs]
  end
end

