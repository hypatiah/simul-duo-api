require 'openssl'
require 'base64'
require 'uri'
require 'net/http'
require 'json'

class Api::DonationsController < ApplicationController

	def setRequest (httpHeader, subURI, body = "")
  		merchant_id = "2272"
  		api_key = ENV['INGENICO_API_KEY']
  		secret_key = ENV["INGENICO_SECRET_KEY"]
  		url = "https://api-sandbox.globalcollect.com"
  		meth = httpHeader 
  		type = "application/json"
  		time = Time.new
  		timestamp = time.strftime("%a, %d %b %Y %H:%M:%S %Z")

  		uri = "/v1/"+merchant_id+subURI
  		endpoint = url+uri
  		header = meth+"\n"+type+"\n"+timestamp+"\n"+uri+"\n"
  		digest = OpenSSL::Digest.new('sha256')
  		decoded_key = Base64.strict_decode64(secret_key)
  		hmac = Base64.strict_encode64(OpenSSL::HMAC.digest(digest, secret_key, header))
  		url = URI(endpoint)
  		http = Net::HTTP.new(url.host, url.port)
  		http.use_ssl = true
  		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  		if httpHeader == "POST"
    		request = Net::HTTP::Post.new(url)
  		elsif httpHeader == "DELETE"
  		  request = Net::HTTP::Delete.new(url)
  		elsif httpHeader == "PUT"
  		  request = Net::HTTP::Put.new(url)
  		else
  		  request = Net::HTTP::Get.new(url)
  		end
  
  		request["Date"] = timestamp
  		request["Content-type"] = type
  		request["authorization"] = "GCS v1HMAC:"+api_key+":"+hmac
  		request.body = body
 
  		response = http.request(request)
  		jsonr = JSON.parse(response.read_body)
  		#puts jsonr
  		return jsonr
		end

	def donate
		# test connection
		response = setRequest('GET', '/services/testconnection')
		# jsonr = JSON.parse(response.read_body)
		# p "10"*80
		puts response

		# create hosted checkout
		body = '{
		  "hostedCheckoutSpecificInput": {
		    "locale": "en_GB", 
		    "variant": "testVariant"
		  }, 
		  "order": {
		    "amountOfMoney": {
		      "currencyCode": "USD", 
		      "amount": 100
		    }, 
		    "customer": {
		      "billingAddress": {
		        "countryCode": "US"
		      }
		    }
		  }
		}'

		response = setRequest('POST', '/hostedcheckouts', body)
		# jsonr = JSON.parse(response.read_body)
		p "9"*80
		p response
		purl = response['partialRedirectUrl']
		hcid = response['hostedCheckoutId']
		p "8"*80
		payment_url = 'https://payment.pay1.' + purl
		# puts payment_url
		# redirect payment_url

		Launchy.open( payment_url ) do |exception|
  		puts "Attempted to open #{uri} and failed because #{exception}"
		end
		render json: { payment_url: payment_url }, status: 200
		p "7"*80 
		puts hcid
		body = ''

		response = setRequest('GET', '/hostedcheckouts/' + hcid, body)
		status = response['status']
		while status == 'IN_PROGRESS' do
		  response = setRequest('GET', '/hostedcheckouts/' + hcid, body)
		  status = response['status']
		end
		paymentOutput = response['createdPaymentOutput']
		paymentId = paymentOutput['payment']['id']
		p "6"*80
		puts paymentOutput
		p "5"*80
		puts paymentId

		#check payment status
		response = setRequest('GET', '/payments/' + paymentId, body)

		paymentStatus = response['status']
		p "4"*80
		puts paymentStatus

		# tokenize 
		body = '{}'
		response = setRequest('POST', '/payments/' + paymentId + '/tokenize', body)
		p "3"*80
		puts response
		# capture payment
		body = '{
		  "paymentMethodSpecificInput": 1
		}'
		response = setRequest('POST', '/payments/' + paymentId + '/approve', body)
		p "2"*80
		puts response

		if paymentStatus == 800
			redirect 
		end

	end

end
