require 'base64'
require 'cgi'
require 'openssl'
require 'net/http'
#permite generar el hash para las distintas autorizaciones, lo retorna



class OrdersController < ApplicationController

	layout false
	def generateHash (contenidoSignature)
		encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
		return encoded_string
	end

	def index
		@hashi = 'INTEGRACION grupo12:'+generateHash('GET'+'').to_s
		puts @hashi
		var_url_get="http://integracion-2016-dev.herokuapp.com/bodega/almacenes"
		uri = URI.parse(var_url_get)
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		request['Authorization'] = @hashi
		response = http.request(request).to_json
		puts response
	  #@response = JSON.parse RestClient.get data_ur_almacenes, {:Authorization => @hashi}
	end


end
#rails g scaffold oc_recibidas id_dev:string created_at_dev:date canal:string sku:string cantidad:integer precio_unit:integer entrega_at:date despacho_at:date estado:string rechazo:string anulacion:string notas:string id_factura_dev:string