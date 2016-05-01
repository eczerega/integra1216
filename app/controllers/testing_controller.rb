
require 'base64'
require 'cgi'
require 'openssl'
require 'net/http'
require 'json'

class TestingController < ApplicationController

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

	def get_almacenes_id
		@all_data = getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/almacenes', 'GET', '')
		@data=Array.new
		@all_data.each_line do |line|
			JSON.parse(line).each do |data_value|
				@data.push(data_value["_id"])
			end
		end
		return @data
	end

	def get_all_sku
		@almacenes = get_almacenes_id
		@all_data = getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock', 'GET', '')

	end

	def all_skus
		@almacenes = get_almacenes_id
		@all_skus=Array.new
		@almacenes.each do |almacen|
			@all_skus.push(getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock?almacenId='+almacen, 'GET'+almacen, ''))
		end
		return @all_skus
	end

	def sku_by_almacen_id(almacen_id)
		@all_skus.push(getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock?almacenId='+almacen, 'GET'+almacen, ''))
	end


	def index
		@all_data = getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/almacenes', 'GET', '')
		@data = get_almacenes_id
		@all_skus=all_skus
	end

end
