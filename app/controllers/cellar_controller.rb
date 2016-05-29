class CellarController < ApplicationController

	def generateHash (contenidoSignature)
		encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','Cfs%agh:i#B8&f6', contenidoSignature)).chomp
		return encoded_string
	end

	def unix_time()
		horas_ = params[:horas].to_i
		puts (DateTime.now).strftime('%Q')

		return (DateTime.now+horas_.hours).strftime('%Q')
	end

	def getJSONData(url_req, url_data, params)
		'ola veve'
		@hashi = 'INTEGRACION grupo12:'+generateHash(url_data).to_s
		puts @hashi
		url = URI.parse(url_req)
		req = Net::HTTP::Get.new(url.to_s)
		req['Authorization'] = @hashi
		res = Net::HTTP.start(url.host, url.port) {|http|
		  http.request(req)
		}
		return res.body		
	end
	def index
		@data = JSON.parse(getJSONData('http://integracion-2016-prod.herokuapp.com/bodega/almacenes', 'GET', ''))
		
	end
end
