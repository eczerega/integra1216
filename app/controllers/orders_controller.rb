require 'base64'
require 'cgi'
require 'openssl'
require 'net/http'
require 'json'

class OrdersController < ApplicationController

	layout false
	def generateHash (contenidoSignature)
		encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
		return encoded_string
	end

	def getJSONData(url_req, url_data, params)
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
		@data = getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/almacenes', 'GET', '')
		@data.each_line do |line|

		end

	  #@response = JSON.parse RestClient.get data_ur_almacenes, {:Authorization => @hashi}
	end


end
#rails g scaffold oc_recibidas id_dev:string created_at_dev:date canal:string sku:string cantidad:integer precio_unit:integer entrega_at:date despacho_at:date estado:string rechazo:string anulacion:string notas:string id_factura_dev:string