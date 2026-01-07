# class WeatherService
#   def self.fetch(city)
#     byebug
#     # api_key = Rails.application.credentials.weather[:api_key]
#     api_key = ENV['WEATHER_API_KEY']
#     url = URI("https://api.openweathermap.org/data/2.5/weather?q=#{city}&units=metric&appid=#{api_key}")

#     response = Net::HTTP.get(url)
#     JSON.parse(response)
#   end
# end

require "net/http"
require "json"

class WeatherService
  def self.fetch(city)
    api_key = ENV["WEATHER_API_KEY"]
    return { error: "API key missing" } if api_key.blank?

    url = URI("https://api.openweathermap.org/data/2.5/weather?q=#{city}&units=metric&appid=#{api_key}")

    response = Net::HTTP.get_response(url)
    data = JSON.parse(response.body)

    if response.is_a?(Net::HTTPSuccess)
      data
    else
      { error: data["message"] || "Unable to fetch weather" }
    end
  rescue StandardError => e
    { error: e.message }
  end
end

