
require 'json'

class ApiController < ApplicationController
	layout false
		def generateHash (contenidoSignature)
			encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
			return encoded_string
		end
	skip_before_filter :verify_authenticity_token

	#Métodos Felipe, Javiera

	def time()
		puts (DateTime.now+5).strftime('%Q')
		@response_default =  {:time => (DateTime.now+5).strftime('%Q') }
		respond_to do |format|		
		  format.html {}
		  format.json { render :json => @response_default.to_json }
		  format.js
		end
	end

	def generar_factura(id_oc)
	  url = URI("http://mare.ing.puc.cl/facturas/")
	  http = Net::HTTP.new(url.host, url.port)

	  request = Net::HTTP::Put.new(url)
	  request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
	  request["authorization"] = 'INTEGRACION grupo12:'+generateHash('PUT'+id_oc).to_s
	  request["cache-control"] = 'no-cache'
	  request.body = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"oc\"\r\n\r\n"+id_oc+"\r\n-----011000010111000001101001--"

	  @response = http.request(request)
	  @response_json = JSON.parse(@response.body)
	  @factura_id = @response_json["_id"]
	  return @factura_id
	end

  def aceptar_orden(id_oc)
  	url = URI("http://mare.ing.puc.cl/oc/recepcionar/"+id_oc)
	http = Net::HTTP.new(url.host, url.port)

	request = Net::HTTP::Post.new(url)
	request["authorization"] = 'INTEGRACION grupo12:'+generateHash('POST'+id_oc).to_s
	request["cache-control"] = 'no-cache'

	@response = http.request(request)
	@response_json = JSON.parse(@response.body)
	return @response_json
  end


  def recibir_factura()
  	@given_idfactura = params[:idfactura]

	#HAPPY PATH RECIBIR FACTURA
	@response_ok =  {:validado => true, :idfactura => @given_idfactura }
	respond_to do |format|		
	  format.html {}
	  format.json { render :json => @response_ok.to_json }
	  format.js
	end
  end

  def enviar_factura(id_factura, id_cliente)
  	url = URI("http://integra"+id_cliente+".ing.puc.cl/api/facturas/recibir/"+id_factura)

	http = Net::HTTP.new(url.host, url.port)

	request = Net::HTTP::Get.new(url)
	request["cache-control"] = 'no-cache'

	@response = http.request(request)
	@response_json = JSON.parse(@response.body)
	puts @response_json
	return @response_json
  end

  def generar_materia_prima
    return 'genero materia prima'
  end

  def recibir_trx
  	#CHEQUEO SI TRANSFERENCIA SE EFECTUO
  	@given_idtrx = params[:idtrx]
  	@given_idfactura = params[:idfactura]

  	#MONTO TRANSACCION
    url = URI("http://mare.ing.puc.cl/banco/trx/"+@given_idtrx)
	http = Net::HTTP.new(url.host, url.port)

	request = Net::HTTP::Get.new(url)
	request["authorization"] = 'INTEGRACION grupo12:'+generateHash('GET'+@given_idtrx).to_s
	request["cache-control"] = 'no-cache'

	@trx = http.request(request)
	@trx_json = JSON.parse(@trx.body)

  	@response =  {:validado => true, :trx => @trx_json }
	@response = @response.to_json
	responsejson = JSON.parse(@response)
	json_array =  responsejson["trx"][0]
	@monto_trx= json_array["monto"]

  	#MONTO FACTURA
	url = URI("http://mare.ing.puc.cl/facturas/"+@given_idfactura)

	http = Net::HTTP.new(url.host, url.port)

	request2 = Net::HTTP::Get.new(url)
	request2["authorization"] = 'INTEGRACION grupo12:'+generateHash('GET'+@given_idfactura).to_s
	request2["cache-control"] = 'no-cache'


	@factura = http.request(request2)
	@factura_array = JSON.parse(@factura.body)

	@factura_json = JSON.parse(@factura_array[0].to_json)
	@monto_factura =  @factura_json["total"]

	if @monto_trx != @monto_factura
		@response_error =  {:validado => false, :idtrx => @given_idtrx, :reason => 'wrong amount of money' }

      respond_to do |format|
          format.html {}
          format.json { render :json => @response_error.to_json }
          format.js
      end
    else 
    	@response_default =  {:default => "mensaje por default" }
		respond_to do |format|		
		  format.html {}
		  format.json { render :json => @response_default.to_json }
		  format.js
		end
	end


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
		@cantidad = got_stock_internal(@oc_sku)
		puts @cantidad
			if @cantidad.to_i >= @oc_cantidad.to_i
				#ACEPTAR ORDEN COMPRA
				puts aceptar_orden(@oc_id)
				#GENERAR
				@factura_id = generar_factura(@oc_id)
				puts @factura_id
				#ENVIAR FACTURA->No lo he testeado porque el otro grupo no tiene implementada la API
				enviar_factura(@factura_id, @oc_cliente)


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
