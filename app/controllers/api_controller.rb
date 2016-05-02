
require 'json'

class ApiController < ApplicationController
	layout false
		def generateHash (contenidoSignature)
			encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
			return encoded_string
		end
skip_before_filter :verify_authenticity_token

#Métodos Felipe, Javiera


  def generar_factura
    return 'genero factura'
  end

  def generar_materia_prima
    return 'genero materia prima'
  end


#END





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

	def got_stock_internal(given_sku)
		@all_data = getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/almacenes', 'GET', '')
		@data = get_almacenes_id
		@all_skus=all_skus
		@response
		@given_id = given_sku
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
      return @cantidad_total.to_i

	end


#B2B 1 FIN-----------------------------------------------------------------------



#B2B 4 ---------------------------------------------------------------------------

	def gestionar_oc
		@id_oc = params[:idoc]
		begin
		url = URI("http://mare.ing.puc.cl/oc/obtener/"+@id_oc)
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Get.new(url)
		request["content-type"] = 'application/json'
		request["cache-control"] = 'no-cache'
		request["postman-token"] = '05f3b66b-3b67-14d4-30ca-5d24a4cbb586'
		

		@response = http.request(request)
		#ACA REVISAMOS LA BDD Y ESAS WEAS
		@response_json = JSON.parse(@response.body)
		@response = @response.body
		@oc_id = @response_json[0]["_id"]
		@oc_notas = @response_json[0]["notas"]
		@oc_cliente = @response_json[0]["cliente"]
		@oc_sku = @response_json[0]["sku"]
		@oc_estado = @response_json[0]["estado"]
		@oc_proveedor = @response_json[0]["proveedor"]
		@oc_fechaDespachos = @response_json[0]["fechaDespachos"]
		@oc_fechaEntrega = @response_json[0]["fechaEntrega"]
		@oc_precioUnitario = @response_json[0]["precioUnitario"]
		@oc_cantidadDespachada = @response_json[0]["cantidadDespachada"]
		@oc_cantidad = @response_json[0]["cantidad"]
		@oc_canal = @response_json[0]["canal"]
		if @oc_proveedor != "12"
			#ANULAR OC
			error = "error: Proveedor " + @oc_proveedor + " inválido"
			@response= error.to_json
		end

		#REVISO MIS SKUS
			@mis_sku = Precio.all
			seProduce= false
			@mis_sku.each do |sku|
				puts sku.SKU
				if sku.SKU==@oc_sku
					seProduce = true
					break
				end
			end
		#FIN

		#REVISO SI SE PRODUCE
		if seProduce==true
		#REVISO SI HAY STOCK
		@cantidad= got_stock_internal(@oc_sku)
			if @cantidad.to_i >= @oc_cantidad.to_i

				


				respond_to do |format|
				  format.html {}
				  format.json { render :json => @response }
				  format.js
				end
			else
				#ANULAR OC
				respond_to do |format|
				  format.html {}
				  format.json { render :json => "error: Sin stock".to_json }
				  format.js
				end				
			end
		else
			#ANULAR OC
			respond_to do |format|

			  format.html {}
			  format.json { render :json => "error: producto no producido".to_json }
			  format.js
			end			
		end
		#END









		
		rescue Exception => e
			puts e.to_s
			respond_to do |format|
			  format.html {}
			  format.json { render :json => "error: BAD request".to_json }
			  format.js
		end
	end

	end


#B2b FIN--------------------------------------------------------------------------





	def index
	end


end
