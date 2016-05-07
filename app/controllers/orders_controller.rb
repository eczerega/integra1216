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

	def unix_time()
		horas_ = params[:horas].to_i
		puts (DateTime.now).strftime('%Q')

		return (DateTime.now+horas_.hours).strftime('%Q')
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

	def getStockJson(num_grupo,sku)
		url_req = "http://integra"+num_grupo.to_s+".ing.puc.cl/api/consultar/"+sku+".json"

		url = URI.parse(url_req)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
		  http.request(req)
		}
		return res.body
	end

	def getEnviarOC(num_grupo,oc_id)
		url_req = "http://integra"+num_grupo.to_s+".ing.puc.cl/api/oc/recibir/"+oc_id

		url = URI.parse(url_req)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
		  http.request(req)
		}
		return res.body
	end

	def getEnviarTrx(num_grupo,trx_id,fact_id)
		url_req = "http://integra"+num_grupo.to_s+".ing.puc.cl/api/pagos/recibir/"+oc_id+"?idfactura="+fact_id

		url = URI.parse(url_req)
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
		  http.request(req)
		}
		return res.body
	end

	def putBodegaJSONData(url_req, params, param_string)
      @hashi = 'INTEGRACION grupo12:'+generateHash('PUT'+param_string).to_s
      puts @hashi
      
      url = URI.parse("http://mare.ing.puc.cl/oc"+url_req)
      req = Net::HTTP::Put.new(url.to_s,initheader = {'Content-Type' =>'application/json'})
      req['Authorization'] = @hashi
      req.body=params
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }

      puts res.code

      if res.code[0]=='4' || res.code[0]=='5'
        puts res
        return "error"
      elsif res.code[0]=='2'
        return res.body
      else
        return "request_error"
      end
  	end

  	def putOCJSONData(url_req, params, param_string)
      @hashi = 'INTEGRACION grupo12:'+generateHash('PUT'+param_string).to_s
      #puts @hashi
      
      url = URI.parse("http://mare.ing.puc.cl/oc"+url_req)
      req = Net::HTTP::Put.new(url.to_s,initheader = {'Content-Type' =>'application/json'})
      req['Authorization'] = @hashi
      req.body=params
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }

      return res.body

      # if res.code[0]=='4' || res.code[0]=='5'
      #   respond_to do |format|
      #     format.html {}
      #     format.json { render :json => res.body }
      #     format.js
      # 	end
      # elsif res.code[0]=='2'
      #   respond_to do |format|
      #     format.html {}
      #     format.json { render :json => res.body }
      #     format.js
      # 	end
      # else
      #   respond_to do |format|
      #     format.html {}
      #     format.json { render :json => res.body }
      #     format.js
      # 	end
      # end
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

	def index
		#@data = getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/almacenes', 'GET', '')
		
		

	  #@response = JSON.parse RestClient.get data_ur_almacenes, {:Authorization => @hashi}
	end

	def comprar_producto()
	  cantidad_ = params[:cantidad].to_s
	  sku_ = params[:sku].to_s

	  grupo_proyecto = Tiempo.where(SKU:sku_).take[:Grupo_Proyecto]
	  puts grupo_proyecto
	  precio_producto = Precio.where(SKU:sku_).take[:Precio_Unitario]
	  tiempo_produccion_prod = Tiempo.where(SKU:sku_).take[:Tiempo_Medio_Producción]
	  puts grupo_proyecto
	  puts precio_producto
	  puts tiempo_produccion_prod

	  id_cliente = InfoGrupo.find_by(num_grupo:grupo_proyecto,ambiente:"produccion").id_grupo
	  id_proveedor = InfoGrupo.find_by(num_grupo:12,ambiente:"produccion").id_grupo

	  if id_proveedor=="572aac69bdb6d403005fb04d"
	  	puts "yay :)"
	  else
	  	puts "nay :("
	  end

	  fecha_entrega = (DateTime.now+tiempo_produccion_prod.hours+1.hours).strftime('%Q')
	  puts fecha_entrega

	  stock = JSON.parse(getStockJson(grupo_proyecto,sku_))["stock"]
	  puts stock

	  if stock.to_i>=cantidad_.to_i
	  	oc_generada = {:canal=>"b2b",:cantidad=>cantidad_,:sku=>sku_,:cliente=>id_cliente,:proveedor=>id_proveedor,:precioUnitario=>precio_producto,:fechaEntrega=>fecha_entrega.to_i,:notas=>"nada"}
	  	jsonbody = JSON.generate(oc_generada)
	  	puts jsonbody

	  	response = putOCJSONData("/crear",jsonbody,"b2b"+cantidad_+sku_+"12")
	  	puts "OC "+response.to_s
	  	oc_id = JSON.parse(response)["_id"]
	  	puts "OC_ID "+oc_id

	  	response2 = getEnviarOC(grupo_proyecto,oc_id)
	  	puts "VALIDACION_OC"+response2

	  	if response2["aceptado"]
	  		id_cliente_banco = InfoGrupo.find_by(num_grupo:grupo_proyecto,ambiente:"produccion").id_banco
	  		id_proveedor_banco = InfoGrupo.find_by(num_grupo:12,ambiente:"produccion").id_banco

	  		trx_id=crear_trx(precio_producto*cantidad_.to_i,id_proveedor_banco,id_cliente_banco)["_id"]
	  	
	  		puts trx_id

	  		puts getEnviarTrx(grupo_proyecto,trx_id)
	  	else
	  		puts "OC enviada no validada"
	  	end

	  	respond_to do |format|
          format.html {}
          format.json { render :json => {} }
          format.js
      	end

	  else
	  	puts "No hay stock suficiente de ese producto para comprar"
	  end	  
	end
end