class TwilioClient

  def initialize
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SSID'],
      ENV['TWILIO_AUTH_TOKEN']
      )
  end

  def send_sms(to, message)
    response = @client.messages.create(
            body: message,
            from: ENV['TWILIO_PHONE_NUMBER'],
            to: to
          )
    puts "Twilio response #{response.sid}"
  end
end