require 'uri'
require 'net/http'
class CashfreePaymentGatewayService

  def initialize(order_params)
    @order_params = order_params
  end

  def perform
    # byebug
    # Build the request body
    request_body = {
      order_amount: @order_params[:order_amount].to_f,
      order_currency: "INR",
      order_id: @order_params[:order_id],
      customer_details: {
        customer_id: @order_params[:customer_id],
        customer_name: @order_params[:customer_name],
        customer_email: @order_params[:customer_email],
        customer_phone: @order_params[:customer_phone]
      },
      order_meta: { return_url: @order_params[:return_url] }
      # order_meta: { return_url: "https://www.abr.test/response?order_id={order_id}" }
    }

    # Set base URL based on environment
    # base_url = Rails.env.production? ? "https://api.cashfree.com" : "https://sandbox.cashfree.com"
    base_url = Rails.env.production? ? "https://sandbox.cashfree.com" : "https://sandbox.cashfree.com"

    # Construct the cURL request
    uri = URI("#{base_url}/pg/orders")
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri)
    req["content-type"] = "application/json"
    req["Accept"] = "application/json"
    req["x-api-version"] = "2022-01-01"
    req["X-Client-Id"] = ENV["CASHFREE_APP_ID"]
    req["X-Client-Secret"] = ENV["CASHFREE_SECRET_KEY"]
    req.body = request_body.to_json
    response = https.request(req)
    puts "CASHFREE RESPONSE ENC BODY : #{response.body}"
    return response.body

    # Send the request and handle the response
    # http_response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    #   http.request(req)
    # end

    # case http_response.code
    # when "200"
    #   # Order created successfully! Parse the response body
    #   response_json = JSON.parse(http_response.body)
    #   session_id = response_json["payment_link"]
    #   return session_id
    # else
    #   raise StandardError, "Error creating order: #{http_response.body}"
    # end
  end

end








# def hit_request req_type, data, end_point
#       p "#{end_point}"
#       bdtraceid = Rails.env.test? ? "BDTRACEID57839" : "BDTRACEID#{Array.new(5){[*'0'..'9'].sample}.join}"
#       cont_type = "application/jose"
#       enc_res = encrypted_request data, bdtraceid, cont_type
#       url = URI(end_point)
#       https = Net::HTTP.new(url.host, url.port)
#       https.use_ssl = true
#       request = Net::HTTP::Post.new(url)
#       request["content-type"] = cont_type
#       request["bd-timestamp"] = Rails.env.test? ? "1681886580" : "#{Time.now.to_i}"
#       request["Accept"] = cont_type
#       request["bd-traceid"] = Rails.env.test? ? "BDTRACEID57839" : bdtraceid
#       request["clientid"] = ENV["BILL_DESK_CLIENT_ID"]
#       request["alg"] = "HS256"
#       puts "BILL DESK HEADER : content-type : #{cont_type}, bd-timestamp: #{Time.now.to_i}, Accept: #{cont_type}, bd-traceid: #{bdtraceid}, clientid: #{ENV["BILL_DESK_CLIENT_ID"]}, alg: HS256 "
#       puts "BILL DESK ENCRYPTED REQUEST : #{enc_res}"
#       request.body = enc_res
#       response = https.request(request)
#       puts "BILL DESK RESPONSE ENC BODY : #{response.body}"
#       return response.body
#     end