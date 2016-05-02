
require 'json'

class ApiController < ApplicationController
	layout false
		def generateHash (contenidoSignature)
			encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
			return encoded_string
		end


#B2B 1-----------------------------------------------------
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

	def got_stock
		@all_data = getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/almacenes', 'GET', '')
		@data = get_almacenes_id
		@all_skus=all_skus
		@response
		@given_id = params[:sku]
		@cantidad_total = 0
		@all_skus.each do |sku|
			@line_json = JSON.parse(sku)
			begin
				@sku_id=@line_json[0]["_id"]
				@sku_total=@line_json[0]["total"].to_i
				if @given_id == @sku_id
					@cantidad_total+= @sku_total
				end
			rescue Exception => e
			end

		end
		@response =  {:stock => @cantidad_total.to_i, :sku => @given_id.to_i }

      respond_to do |format|
          format.html {}
          format.json { render :json => @response.to_json }
          format.js
      end
	end
#B2B 1 FIN-----------------------------------------------------------------------






	def index
	end


end
