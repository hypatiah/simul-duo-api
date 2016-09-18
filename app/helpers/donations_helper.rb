# module DonationsHelper

# 	def setRequest (httpHeader, subURI, body = "")
#   	merchant_id = "2272"
#   	api_key = ENV["INGENICO_API_KEY"]
#   	secret_key = ENV["INGENICO_SECRET_KEY"]
#   	url = "https://api-sandbox.globalcollect.com"
#   	meth = httpHeader 
#   	type = "application/json"
#   	time = Time.new
#   	timestamp = time.strftime("%a, %d %b %Y %H:%M:%S %Z")
#   	uri = "/v1/"+merchant_id+subURI
#   	endpoint = url+uri
#   	header = meth+"\n"+type+"\n"+timestamp+"\n"+uri+"\n"
#   	digest = OpenSSL::Digest.new('sha256')
#   	decoded_key = Base64.strict_decode64(secret_key)
#   	hmac = Base64.strict_encode64(OpenSSL::HMAC.digest(digest, secret_key, header))
#   	url = URI(endpoint)
#   	http = Net::HTTP.new(url.host, url.port)
#   	http.use_ssl = true
#   	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#   	if httpHeader == "POST"
#     	request = Net::HTTP::Post.new(url)
#   	elsif httpHeader == "DELETE"
#   	  request = Net::HTTP::Delete.new(url)
#   	elsif httpHeader == "PUT"
#   	  request = Net::HTTP::Put.new(url)
#   	else
#   	  request = Net::HTTP::Get.new(url)
#   	end

#   	request["Date"] = timestamp
#   	request["Content-type"] = type
#   	request["authorization"] = "GCS v1HMAC:"+api_key+":"+hmac
#   	request.body = body

#   	response = http.request(request)
#   	jsonr = JSON.parse(response.read_body)
#   	#puts jsonr
#   	return jsonr
#   end
  
# end