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
		url_req = "http://integra"+num_grupo.to_s+".ing.puc.cl/api/oc/recibir/"+oc_id+".json"

		if 
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
        puts res.body
        return "error"
      elsif res.code[0]=='2'
        return res.body
      else
        return "request_error"
      end
  	end

	def index
		@data = getJSONData('http://integracion-2016-dev.herokuapp.com/bodega/almacenes', 'GET', '')
		
		@data.each_line do |line|

		end

	  #@response = JSON.parse RestClient.get data_ur_almacenes, {:Authorization => @hashi}
	end

	def comprar_producto()
	  cantidad_ = params[:cantidad].to_s
	  sku_ = params[:sku].to_s

	  grupo_proyecto = Tiempo.where(SKU:sku_).take[:Grupo_Proyecto]
	  precio_producto = Tiempo.where(SKU:sku_).take[:Costo_produccion_unitario]
	  tiempo_produccion_prod = Tiempo.where(SKU:sku_).take[:Tiempo_Medio_Producción]
	  puts grupo_proyecto
	  puts precio_producto
	  puts tiempo_produccion_prod

	  fecha_entrega = (DateTime.now+tiempo_produccion_prod.hours+1.hours).strftime('%Q')
	  puts fecha_entrega

	  stock = JSON.parse(getStockJson(grupo_proyecto,sku_))["stock"]
	  puts stock

	  #cambiar < !!!
	  if stock.to_i<=cantidad_.to_i
	  	oc_generada = {:canal=>"b2b",:cantidad=>cantidad_,:sku=>sku_,:cliente=>"12",:proveedor=>grupo_proyecto,:precioUnitario=>precio_producto,:fechaEntrega=>fecha_entrega.to_i,:notas=>"nada"}
	  	jsonbody = JSON.generate(oc_generada)
	  	puts jsonbody

	  	response = putOCJSONData("/crear",jsonbody,"b2b"+cantidad_+sku_+"12")
	  	oc_id = JSON.parse(response)["_id"]
	  	puts oc_id
	  else
	  	puts "No hay stock suficiente de ese producto para comprar"
	  end	  

	  respond_to do |format|
        format.json {  }
      end
	end
end