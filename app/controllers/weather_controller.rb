require "net/http"
require "json"

class WeatherController < ApplicationController
  
  def index
    city = params[:city] || "Delhi"
    data = WeatherService.fetch(city)

    # city = params[:city] || "Delhi"
    # api_key = Rails.application.credentials.weather[:api_key]

    # url = URI("https://api.openweathermap.org/data/2.5/weather?q=#{city}&units=metric&appid=#{api_key}")

    # response = Net::HTTP.get(url)
    # data = JSON.parse(response)

    if data[:error]
      @error = data[:error]
    else
      @weather = {
        city: data["name"],
        temperature: data["main"]["temp"].round,
        description: data["weather"][0]["description"].titleize,
        humidity: data["main"]["humidity"],
        wind_speed: data["wind"]["speed"],
        feels_like: (data["main"]["feels_like"] || data["main"]["temp"]).round,
        icon: data["weather"][0]["icon"]
      }
    end
  end
end
