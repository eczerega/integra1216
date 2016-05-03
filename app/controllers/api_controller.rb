
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

	def getOCJSON(id_oc)
		url = URI("http://mare.ing.puc.cl/oc/obtener/"+id_oc)

		http = Net::HTTP.new(url.host, url.port)

		request2 = Net::HTTP::Get.new(url)
		request2["cache-control"] = 'no-cache'

		@oc = http.request(request2)
		@oc_array = JSON.parse(@oc.body)

		@oc_json = JSON.parse(@oc_array[0].to_json)
		
		return @oc_json
	end

	def getFacturaJSON(id_fac)
		url = URI("http://mare.ing.puc.cl/facturas/"+id_fac)

		http = Net::HTTP.new(url.host, url.port)

		request2 = Net::HTTP::Get.new(url)
		request2["authorization"] = 'INTEGRACION grupo12:'+generateHash('GET'+id_fac).to_s
		request2["cache-control"] = 'no-cache'

		@factura = http.request(request2)
		@factura_array = JSON.parse(@factura.body)

		@factura_json = JSON.parse(@factura_array[0].to_json)
		
		return @factura_json
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

  def anular_orden(id_oc, respuesta)
  	url = URI("http://mare.ing.puc.cl/oc/anular/"+id_oc)
	http = Net::HTTP.new(url.host, url.port)
	request = Net::HTTP::Delete.new(url)
	request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
	request["authorization"] = 'INTEGRACION grupo12cvrkpgZRptPWtoDFmyr9n3dtzfc='
	request["cache-control"] = 'no-cache'
	request["postman-token"] = '852f5544-3be3-d8f2-e8eb-24db50cfc6cc'
	request.body = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"id\"\r\n\r\n"+id_oc+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"anulacion\"\r\n\r\n"+ respuesta +"\r\n-----011000010111000001101001--"
	response = http.request(request)
	return response
  end


  def recibir_factura()
  	@given_idfactura = params[:idfactura]
  	
  	json_factura = getFacturaJSON(@given_idfactura)
  	puts json_factura

  	oc_id = json_factura["oc"]
  	puts oc_id
  	bruto = json_factura["bruto"]
  	puts bruto

  	json_oc = getOCJSON(oc_id)
  	puts json_oc

  	coincide_total = false
	coincide_cliente = false

	if json_factura["total"]==json_oc["precioUnitario"]
		coincide_total = true
	end

	if json_factura["cliente"]==json_oc["cliente"]
		coincide_cliente = true
	end

	#HAPPY PATH RECIBIR FACTURA
	@response_ok =  {:validado => coincide_cliente && coincide_total, :idfactura => @given_idfactura }
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
	puts "TRANSACCION" + json_array.to_s + "\n"
	@monto_trx= json_array["monto"]
	@destino_trx = json_array["destino"]
	puts "CUENTA DESTINO" + @destino_trx + "\n"


  	#MONTO FACTURA
	@factura_json = getFacturaJSON(@given_idfactura)

	@monto_factura =  @factura_json["total"]


	@cuenta_banco = "571262c3a980ba030058ab65"

	#EN ESTE CASO HAY QUE ESTABLECER POLITICA DE DEPOSITO POR CANTIDAD INCORRECTA
	if @destino_trx != @cuenta_banco
      @response_error =  {:validado => false, :idtrx => @given_idtrx, :reason => 'Cuenta destino errónea' }

      respond_to do |format|
          format.html {}
          format.json { render :json => @response_error.to_json }
          format.js
      end
	
	elsif @monto_trx != @monto_factura
	  @response_error =  {:validado => false, :idtrx => @given_idtrx, :reason => 'Cantidad transferida errónea' }

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

	def mover_a_bodega(id_producto, id_almacen)
      	url = URI("http://integracion-2016-dev.herokuapp.com/bodega/moveStock")
	    http = Net::HTTP.new(url.host, url.port)
	    request = Net::HTTP::Post.new(url)
	    @hashi_get = 'INTEGRACION grupo12:'+generateHash('POST'+ id_producto + id_almacen).to_s
	    request["authorization"] = @hashi_get
	    request["content-type"] = 'application/json'
	    request["cache-control"] = 'no-cache'
	    request["postman-token"] = 'afdedc9a-5265-3c5b-971d-16c402393539'
	    request.body = "{\n    \"almacenId\": \""+ id_almacen +"\",\n    \"productoId\": \""+id_producto+"\"\n}"
	    response = http.request(request)
	    #puts response.read_body
	  end

	def contarProductos(almacenId, sku)
      url = URI("http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock?almacenId="+almacenId)
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET'+ almacenId).to_s
      request["authorization"] = @hashi_get
      request["content-type"] = 'application/json'
      request["cache-control"] = 'no-cache'
      request["postman-token"] = '07cc8b55-6f45-f987-1c5a-0eb4f9648baa'
      response = http.request(request)
      puts response.body
      total = 0
      JSON.parse(response.body).each do |line|
        if sku == line["_id"]
          total += line["total"].to_i
        end
      end
      return total
 	end

	def iterarProductos(almacenId, sku, qty)
    @almacen_despacho = '571262aba980ba030058a5c7'
    url = URI("http://integracion-2016-dev.herokuapp.com/bodega/stock?almacenId=" + almacenId + "&sku=" + sku + "&limit=199" )
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url)
    @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET'+ almacenId + sku).to_s
    request["authorization"] = @hashi_get 
    request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
    request["cache-control"] = 'no-cache'
    request["postman-token"] = '2d38d414-b654-7ea2-d7f2-e1379efa0526'
    response = http.request(request)
    JSON.parse(response.body).each do |line|
      @producto_a_mover = line["_id"].to_s
      mover_a_bodega(@producto_a_mover, @almacen_despacho)
      qty -= 1
	      if qty == 0
	        return qty
	      end
	  end
	  return qty
	end

	def despachar(id_oc, sku, cantidad)
		###FALTA IMPLEMENTAR ESTE METODO
  	end

  	def preparar_despacho(id_oc, sku, cantidad)

      #571262aba980ba030058a5c7 despacho
      #571262aa980ba030058a5c6 recepcion
      #571262aba980ba030058a5d7 pulmon
      #571262aba980ba030058a5c8 otra
      #571262aba980ba030058a5d6 otra
      almacen_despacho = '571262aba980ba030058a5c7'
      current_stock = contarProductos(almacen_despacho, sku)
      if cantidad <= current_stock
        puts "listos para despachar"
        ###despachar()
      else
        puts "debemos mover cosas"
        @mis_almacenes = ["571262aba980ba030058a5d7", "571262aba980ba030058a5c6", "571262aba980ba030058a5c8", "571262aba980ba030058a5d6"]
        faltante = cantidad - current_stock
        ###REVISO SI EN TODOS MIS ALMACENES TENGO STOCK
        @mis_almacenes.each do |almacen|
          faltante += contarProductos(almacen, sku)
          if cantidad <= faltante + current_stock
            break
          end
        end

        ###UNA VEZ CONFIRMADO MI STOCK, MUEVO LOS PRODUCTOS PARA EL DESPACHO
        if cantidad <= faltante + current_stock
          @mis_almacenes.each do |almacen|
            faltante = iterarProductos(almacen, sku, faltante)
            puts 'faltan ' + faltante.to_s  
            if faltante == 0
              break
            end
          end
          puts "despachamos!"
          ###despachar()
        else
          ###NO SE PUEDE DESPACHAR
        end
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
			resp_json = {:aceptado => false, :idoc => @oc_id.to_s}.to_json
			my_hash = JSON.parse(resp_json)
			respond_to do |format|
			  format.html {}
			  format.json { render :json => my_hash}
			  format.js
			end
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
				#RETORNAR {aceptado,idoc}
				@response = {:aceptado => true, :idoc => @id_oc}
				#ACEPTAR ORDEN COMPRA
				puts aceptar_orden(@oc_id)
				#GENERAR
				@factura_id = generar_factura(@oc_id)
				puts @factura_id
				#ENVIAR FACTURA->No lo he testeado porque el otro grupo no tiene implementada la API
				enviar_factura(@factura_id, @oc_cliente)


				###UNA VEZ CHEQUEADO EL PAGO, REALIZAMOS EL DESPACHO
				preparar_despacho(@oc_id.to_s, @oc_sku, @oc_cantidad)


				resp_json = {:aceptado => true, :idoc => @oc_id.to_s}.to_json
				my_hash = JSON.parse(resp_json)

				respond_to do |format|
				  format.html {}
				  format.json { render :json => my_hash}
				  format.js
				end
			else
				#ANULAR OC
				resp_json = {:aceptado => false, :idoc => @oc_id.to_s}.to_json
				my_hash = JSON.parse(resp_json)

				respond_to do |format|
				  format.html {}
				  format.json { render :json => my_hash}
				  format.js
				end			
			end
		else
			#ANULAR OC
			resp_json = {:aceptado => false, :idoc => @oc_id.to_s}.to_json
			my_hash = JSON.parse(resp_json)

			respond_to do |format|
			  format.html {}
			  format.json { render :json => my_hash}
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
