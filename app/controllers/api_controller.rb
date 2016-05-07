require 'json'
require 'net/http'

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

	def crear_trx(monto, origenId, destinoId)
		dinero = monto.to_s
		url = URI("http://mare.ing.puc.cl/banco/trx")
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Put.new(url)
		request["content-type"] = 'application/json'
		request["cache-control"] = 'no-cache'
		request["postman-token"] = 'a6719103-e787-baf6-90db-0618b6f3da85'
		request.body = "{\n    \"monto\": \""+ dinero +"\",\n    \"origen\": \""+ origenId +"\",\n    \"destino\": \""+ destinoId +"\"\n}"
		response = http.request(request)
		puts response.read_body
	end

	def crear_trx_exp()
		origenId=params["origen"].to_s
		destinoId=params["destino"].to_s
		dinero = params["monto"].to_i
		url = URI("http://mare.ing.puc.cl/banco/trx")
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Put.new(url)
		request["content-type"] = 'application/json'
		request["cache-control"] = 'no-cache'
		request["postman-token"] = 'a6719103-e787-baf6-90db-0618b6f3da85'
		request.body = "{\n    \"monto\": \""+ dinero.to_s+"\",\n    \"origen\": \""+ origenId +"\",\n    \"destino\": \""+ destinoId +"\"\n}"
		response = http.request(request)
		puts response.read_body

		respond_to do |format|
	          format.html {}
	          format.json { render :json => response.read_body }
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

	def rechazar_factura(facturaId, motivo)
		url = URI("http://mare.ing.puc.cl/facturas/reject")
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Post.new(url)
		request["content-type"] = 'application/json'
		request["cache-control"] = 'no-cache'
		request["postman-token"] = '485a9988-376e-7e60-d24f-6b728a38ed7f'
		request.body = "{\n    \"id\": \""+ facturaId +"\",\n    \"motivo\": \""+ motivo +"\"\n}"
		response = http.request(request)
		puts response.read_body
	end

	def anular_factura(facturaId, motivo)
		url = URI("http://mare.ing.puc.cl/facturas/cancel")
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Post.new(url)
		request["content-type"] = 'application/json'
		request["cache-control"] = 'no-cache'
		request["postman-token"] = '485a9988-376e-7e60-d24f-6b728a38ed7f'
		request.body = "{\n    \"id\": \""+ facturaId +"\",\n    \"motivo\": \""+ motivo +"\"\n}"
		response = http.request(request)
		puts response.read_body
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

	def rechazar_orden(id_oc, respuesta)
	  	url = URI("http://mare.ing.puc.cl/oc/rechazar/"+id_oc)
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Post.new(url)
		request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
		request["authorization"] = 'INTEGRACION grupo12cvrkpgZRptPWtoDFmyr9n3dtzfc='
		request["cache-control"] = 'no-cache'
		request["postman-token"] = '852f5544-3be3-d8f2-e8eb-24db50cfc6cc'
		request.body = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"id\"\r\n\r\n"+id_oc+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"rechazo\"\r\n\r\n"+ respuesta +"\r\n-----011000010111000001101001--"
		response = http.request(request)
		return response
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
		if json_factura["total"]==json_oc["precioUnitario"].to_i * json_oc["cantidad"]
			coincide_total = true
		else
			motivo = 'Monto incorrecto'
		end

		if json_factura["cliente"]==json_oc["cliente"] #QUIZAS VALIDAR TAMBIEN QUE EL CLIENTE SOMOS NOSOTROS
			coincide_cliente = true
		else
			motivo = 'Cliente no coincide'
		end

		if coincide_cliente && coincide_total
			puts oc_id
			puts @given_idfactura
			foc = FacturaOc.find_by(oc_id: oc_id.to_s, factura_id: @given_idfactura)
			puts foc
			foc.estado = "factura por pagar"
			foc.save

			@response_ok =  {:validado => true, :idfactura => @given_idfactura }
			respond_to do |format|		
			  format.html {}
			  format.json { render :json => @response_ok.to_json }
			  format.js
			end
		else
			rechazar_factura(@given_idfactura, motivo)
			foc = FacturaOc.find_by(oc_id: oc_id.to_s, factura_id: @given_idfactura)
			puts foc
			foc.estado = "factura rechazada"
			foc.save

			@response_ok =  {:validado => false, :idfactura => @given_idfactura }
			respond_to do |format|		
			  format.html {}
			  format.json { render :json => @response_ok.to_json }
			  format.js
			end
		end
  	end

	def enviar_factura(id_factura, id_cliente)
	  	num_grupo="0"

	  	if id_cliente=="571262b8a980ba030058ab4f"
	  		num_grupo="1"
	  	elsif id_cliente=="571262b8a980ba030058ab50"
	  		num_grupo="2"
	  	elsif id_cliente=="571262b8a980ba030058ab51"
	  		num_grupo="3"
	  	elsif id_cliente=="571262b8a980ba030058ab52"
	  		num_grupo="4"
	  	elsif id_cliente=="571262b8a980ba030058ab53"
	  		num_grupo="5"
	  	elsif id_cliente=="571262b8a980ba030058ab54"
	  		num_grupo="6"
	  	elsif id_cliente=="571262b8a980ba030058ab55"
	  		num_grupo="7"
	  	elsif id_cliente=="571262b8a980ba030058ab56"
	  		num_grupo="8"
	  	elsif id_cliente=="571262b8a980ba030058ab57"
	  		num_grupo="9"
	  	elsif id_cliente=="571262b8a980ba030058ab58"
	  		num_grupo="10"
	  	elsif id_cliente=="571262b8a980ba030058ab59"
	  		num_grupo="11"
	  	elsif id_cliente=="571262b8a980ba030058ab5a"
	  		num_grupo="12"
	  	end

	  	url = URI("http://integra"+num_grupo+".ing.puc.cl/api/facturas/recibir/"+id_factura)

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
		@origen_trx = json_array["origen"]
		@destino_trx = json_array["destino"]
		puts "CUENTA DESTINO" + @destino_trx + "\n"


	  	#MONTO FACTURA
		@factura_json = getFacturaJSON(@given_idfactura)
		@oc_id = @factura_json["oc"]
		@monto_factura =  @factura_json["total"]


		@cuenta_banco = "571262c3a980ba030058ab65"

		#EN ESTE CASO HAY QUE ESTABLECER POLITICA DE DEPOSITO POR CANTIDAD INCORRECTA
		if @destino_trx != @cuenta_banco
	    	@response_error =  {:validado => false, :idtrx => @given_idtrx, :reason => 'Cuenta destino errónea' }
	    	anular_factura(@given_idfactura,"Cuenta destino errónea")
	    	foc = FacturaOc.find_by(oc_id: @oc_id.to_s, factura_id: @given_idfactura)
			puts foc
			foc.estado = "factura anulada"
			foc.save

	    	respond_to do |format|
	        	format.html {}
	        	format.json { render :json => @response_error.to_json }
	        	format.js
	    	end
		elsif @monto_trx != @monto_factura
			@response_error =  {:validado => false, :idtrx => @given_idtrx, :reason => 'Cantidad transferida errónea' }
			anular_factura(@given_idfactura,"Cantidad transferida errónea")
	    	foc = FacturaOc.find_by(oc_id: @oc_id.to_s, factura_id: @given_idfactura)
			puts foc
			foc.estado = "factura anulada"
			foc.save

	    	respond_to do |format|
	          format.html {}
	          format.json { render :json => @response_error.to_json }
	          format.js
	    	end
	    else 
	    	@response_default =  {:validado => true, :idtrx =>  @given_idtrx}
			foc = FacturaOc.find_by(oc_id: @oc_id.to_s, factura_id: @given_idfactura)
			puts foc
			foc.estado = "factura pagada"
			foc.save
			orden = OcRecibidas.find_by(id_dev: @oc_id)
			@oc_precioUnitario = orden.precio_unit
			@oc_cantidad = orden.cantidad
			@oc_sku = orden.sku
			info = InfoGrupo.find_by(id_banco: @origen_trx)
			almacen_destino = info.id_almacen

			respond_to do |format|		
			  format.html {}
			  format.json { render :json => @response_default.to_json }
			  format.js
			end

			###UNA VEZ CHEQUEADO EL PAGO, REALIZAMOS EL DESPACHO
			preparar_despacho(@oc_id.to_s, @oc_sku, @oc_cantidad, @oc_precioUnitario, almacen_destino)

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

	def despachar(id_oc, sku, cantidad, producto, almacen_destino, precio)
		price = precio.to_s
		url = URI("http://integracion-2016-dev.herokuapp.com/bodega/moveStockBodega")
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Post.new(url)
		@hashi_get = 'INTEGRACION grupo12:'+generateHash('POST'+ producto + almacen_destino).to_s
		request["authorization"] = @hashi_get
		request["content-type"] = 'application/json'
		request["cache-control"] = 'no-cache'
		request["postman-token"] = '7c74eec3-c1a9-1624-54f8-ece518f4775d'
		request.body = "{\n    \"productoId\": \""+ producto +"\",\n    \"almacenId\": \""+ almacen_destino +"\",\n    \"oc\": \""+ id_oc +"\",\n    \"precio\": "+ price+"\n}"
		response = http.request(request)
		puts response.read_body 
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

	def moverProductos(id_oc, almacenId, destinoId, sku, cantidad, faltante, precio)
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
        puts @producto_a_mover

        if almacenId != @almacen_despacho
          puts "moviendo a despacho..."
          mover_a_bodega(@producto_a_mover, @almacen_despacho)
        end

        puts "despachando desde " + almacenId + " hacia " + destinoId + "..."
        despachar(id_oc, sku, cantidad, @producto_a_mover, destinoId, precio)
        faltante -= 1

        if faltante == 0
            return faltante
        end
        
      end
	  return faltante
	end

  	def preparar_despacho(id_oc, sku, cantidad, precio, almacen_destino)

      #571262aba980ba030058a5c7 despacho
      #571262aa980ba030058a5c6 recepcion
      #571262aba980ba030058a5d7 pulmon
      #571262aba980ba030058a5c8 otra
      #571262aba980ba030058a5d6 otra
      almacen_despacho = '571262aba980ba030058a5c7'
      stock_en_despacho = contarProductos(almacen_despacho, sku)
      if cantidad <= stock_en_despacho
        puts "listos para despachar"
        faltante = moverProductos(id_oc, almacen_despacho, almacen_destino, sku, cantidad, cantidad, precio)
      else
        puts "debemos mover cosas"
        @mis_almacenes = ["571262aba980ba030058a5d7", "571262aba980ba030058a5c6", "571262aba980ba030058a5c8", "571262aba980ba030058a5d6"]
        stock_otras_bodegas = 0
        faltante = cantidad - stock_en_despacho
        ###REVISO SI EN TODOS MIS ALMACENES TENGO STOCK
        @mis_almacenes.each do |almacen|
          stock_otras_bodegas += contarProductos(almacen, sku)
          if cantidad <= stock_otras_bodegas + stock_en_despacho
            break
          end
        end
        ###UNA VEZ CONFIRMADO MI STOCK, MUEVO LOS PRODUCTOS PARA EL DESPACHO
        if cantidad <= stock_otras_bodegas + stock_en_despacho
          faltante = moverProductos(id_oc, almacen_despacho, almacen_destino, sku, cantidad, faltante, precio)
          @mis_almacenes.each do |almacen|
            faltante = moverProductos(id_oc, almacen, almacen_destino, sku, cantidad, faltante, precio)
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

	def contarTotal()
		sku = params[:sku]
		url = URI("http://integracion-2016-dev.herokuapp.com/bodega/almacenes")
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Get.new(url)
		@hashi_get = 'INTEGRACION grupo12:'+generateHash('GET').to_s
		request["authorization"] = @hashi_get
		request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
		request["cache-control"] = 'no-cache'
		request["postman-token"] = '87c4769c-086d-7a1a-a299-d68b4be2f76a'
		response = http.request(request)
		total = 0
		JSON.parse(response.body).each do |line|
			almacen = line["_id"]
			puts almacen
			total += contarProductos(almacen, sku)
	    end
	    #return total
	    hash_res = {:stock=>total,:sku=>sku}

    	respond_to do |format|
			format.html {}
			format.json { render :json => hash_res}
			format.js
		end	
	end

	def contarTotal2(sku)
		#sku = params[:sku]
		url = URI("http://integracion-2016-dev.herokuapp.com/bodega/almacenes")
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Get.new(url)
		@hashi_get = 'INTEGRACION grupo12:'+generateHash('GET').to_s
		request["authorization"] = @hashi_get
		request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
		request["cache-control"] = 'no-cache'
		request["postman-token"] = '87c4769c-086d-7a1a-a299-d68b4be2f76a'
		response = http.request(request)
		total = 0
		JSON.parse(response.body).each do |line|
			almacen = line["_id"]
			puts almacen
			total += contarProductos(almacen, sku)
	    end
	    return total
	 #    hash_res = {:stock=>total,:sku=>sku}

  #   	respond_to do |format|
		# 	format.html {}
		# 	format.json { render :json => hash_res}
		# 	format.js
		# end	
	end

	def got_stock_string
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
		@response =  {:stock => @cantidad_total.to_s, :sku => @given_id.to_s }

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
			@oc_creado = @response_json[0]["created_at"]



			if !(@oc_proveedor.to_s == "572aac69bdb6d403005fb04d")
				rechazar_orden(@oc_id, 'Grupo no corresponde')
				resp_json = {:aceptado => false, :idoc => @oc_id.to_s}.to_json
				my_hash = JSON.parse(resp_json)
				respond_to do |format|
				  format.html {}
				  format.json { render :json => my_hash}
				  format.js
				end
			elsif @oc_estado!="creada"
				resp_json = {:aceptado => false, :idoc => @oc_id.to_s}.to_json
				my_hash = JSON.parse(resp_json)
				respond_to do |format|
				  format.html {}
				  format.json { render :json => my_hash}
				  format.js
				end
			else
				#REVISO MIS SKUS
				puts @oc_sku
				@mis_sku = Precio.all
				puts @mis_sku
				seProduce= false
				precioCorrecto= false
				
				@mis_sku.each do |sku|
					puts sku.SKU
					if sku.SKU==@oc_sku.to_s
						seProduce = true
						if @oc_precioUnitario.to_i < sku.Precio_Unitario
							rechazar_orden(@oc_id, 'Precio incorrecto')
							resp_json = {:aceptado => false, :idoc => @oc_id.to_s}.to_json
							my_hash = JSON.parse(resp_json)

							respond_to do |format|
							  format.html {}
							  format.json { render :json => my_hash}
							  format.js
							end		
						else
							precioCorrecto = true
						end
						break
					end
				end



				#FIN

				#REVISO SI SE PRODUCE
				if seProduce==true && precioCorrecto == true
					#REVISO SI HAY STOCK
					#@cantidad = got_stock_internal(@oc_sku)
					@cantidad = contarTotal2(@oc_sku)
					puts @cantidad
					if @cantidad.to_i >= @oc_cantidad.to_i
						#RETORNAR {aceptado,idoc}
						@response = {:aceptado => true, :idoc => @id_oc}
						#CREAR ORDEN EN LA BDD
						#ACEPTAR ORDEN COMPRA
						puts aceptar_orden(@oc_id)
						#GENERAR
						@factura_id = generar_factura(@oc_id)
						puts @factura_id
						OcRecibidas.create(id_dev:@oc_ic, created_at_dev: canal:@oc_canal, sku:@oc_sku, cantidad:@oc_cantidad, precio_unit:@oc_precioUnitario, entrega_at:@oc_fechaEntrega, despacho_at:@oc_fechaEntrega, estado:@oc_estado, rechazo:'', anulacion:'', id_factura_dev:@factura_id)
						
						FacturaOc.create(factura_id:@factura_id, oc_id:@id_oc, estado:"creada")
						#ENVIAR FACTURA->No lo he testeado porque el otro grupo no tiene implementada la API
						fact_resp = enviar_factura(@factura_id, @oc_cliente)
						if fact_resp["validado"]
							foc = FacturaOc.find_by(oc_id: @oc_id.to_s, factura_id: @factura_id)
							puts foc
							foc.estado = "factura aceptada por cliente"
							orden_compra = OcRecibidas.find_by(id_dev:@oc_ic)
							orden_compra.estado = 'aceptada'
							foc.save
						else
							foc = FacturaOc.find_by(oc_id: @oc_id.to_s, factura_id: @factura_id)
							puts foc
							foc.estado = "factura rechazada por cliente"
							orden_compra = OcRecibidas.find_by(id_dev:@oc_ic)
							orden_compra.estado = 'anulada'
							foc.save
						end

						resp_json = {:aceptado => true, :idoc => @oc_id.to_s}.to_json
						my_hash = JSON.parse(resp_json)

						respond_to do |format|
						  format.html {}
						  format.json { render :json => my_hash}
						  format.js
						end
					else
						rechazar_orden(@oc_id, 'No hay stock')
						puts "hola2"
						resp_json = {:aceptado => false, :idoc => @oc_id.to_s}.to_json
						my_hash = JSON.parse(resp_json)

						respond_to do |format|
						  format.html {}
						  format.json { render :json => my_hash}
						  format.js
						end			
					end
				elsif seProduce == false
					puts "hola3"
					rechazar_orden(@oc_id, 'No producimos esta cosa')
					resp_json = {:aceptado => false, :idoc => @oc_id.to_s}.to_json
					my_hash = JSON.parse(resp_json)

					respond_to do |format|
					  format.html {}
					  format.json { render :json => my_hash}
					  format.js
					end		
				end
			end		
		rescue Exception => e
			puts e.to_s
			respond_to do |format|
			  format.html {}
			  format.json { render :json => "error: BAD request".to_json }
			  format.js
			end
		end
	end
end
