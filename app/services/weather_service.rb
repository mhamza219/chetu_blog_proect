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

    if api_key.blank?
      return mock_weather(city)
    end

    url = URI("https://api.openweathermap.org/data/2.5/weather?q=#{city}&units=metric&appid=#{api_key}")

    response = Net::HTTP.get_response(url)
    
    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    elsif response.code == "401"
      mock_weather(city)
    else
      data = JSON.parse(response.body)
      { error: data["message"] || "Unable to fetch weather" }
    end
  rescue StandardError => e
    mock_weather(city)
  end

  def self.mock_weather(city)
    hash = city.downcase.chars.map(&:ord).sum
    
    conditions = ["clear sky", "few clouds", "scattered clouds", "broken clouds", "rain", "thunderstorm", "snow", "mist"]
    condition = conditions[hash % conditions.length]
    
    temp = 12 + (hash % 26) # 12 to 37 °C
    humidity = 35 + (hash % 56) # 35% to 90%
    wind_speed = 1.2 + (hash % 88) / 10.0 # 1.2 to 9.9 m/s
    
    {
      "name" => city.strip.split.map(&:capitalize).join(' '),
      "main" => {
        "temp" => temp,
        "humidity" => humidity,
        "feels_like" => temp + [-2, -1, 0, 1, 2][hash % 5]
      },
      "weather" => [
        {
          "description" => condition,
          "main" => condition.split.last.capitalize,
          "icon" => mock_icon(condition)
        }
      ],
      "wind" => {
        "speed" => wind_speed
      }
    }
  end

  def self.mock_icon(condition)
    case condition
    when "clear sky" then "01d"
    when "few clouds" then "02d"
    when "scattered clouds" then "03d"
    when "broken clouds" then "04d"
    when "rain" then "09d"
    when "thunderstorm" then "11d"
    when "snow" then "13d"
    else "50d"
    end
  end
end

