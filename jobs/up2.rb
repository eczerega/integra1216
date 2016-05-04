require 'rubygems'
require 'rest-client'
require 'base64'
require 'cgi'
require 'openssl'
require 'hmac-sha1'
require 'json'
require 'net/http'

#permite generar el hash para las distintas autorizaciones, lo retorna
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
			@data.push(data_value["_id"].to_s+';'+data_value["totalSpace"].to_s+';'+data_value["recepcion"].to_s+';'+data_value["pulmon"].to_s+';'+data_value["despacho"].to_s)
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

def getSKUData(url_req, url_data, params)
	@hashi = 'INTEGRACION grupo12:'+generateHash(url_data).to_s
	return @hashi

end


def gethash(almacenid)

	@hash= generateHash('GET'+almacenid)
	puts @hash
end



#MANDAR A COMPRAR MATERIAS PRIMAS

url_bodega="http://integracion-2016-dev.herokuapp.com/bodega"

 
  def getBodegaJSONData(url_req, param_string)
      @hashi = 'INTEGRACION grupo12:'+generateHash('GET'+param_string).to_s
      url = URI.parse("http://integracion-2016-dev.herokuapp.com/bodega/"+url_req)
      req = Net::HTTP::Get.new(url.to_s)
      req['Authorization'] = @hashi
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
 
      return res.body
  end
 
  def getBancoJSONData(url_req)
      @hashi = 'INTEGRACION grupo12:'+generateHash('GET').to_s
      url = URI.parse("http://mare.ing.puc.cl/banco/"+url_req)
      req = Net::HTTP::Get.new(url.to_s)
      #req['Authorization'] = @hashi
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
 
      return res.body
  end
 
  def putBodegaJSONData(url_req, params, param_string)
      @hashi = 'INTEGRACION grupo12:'+generateHash('PUT'+param_string).to_s
      puts @hashi
     
      url = URI.parse("http://integracion-2016-dev.herokuapp.com/bodega/"+url_req)
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
 
  def putBancoJSONData(url_req, params)
   
      url = URI.parse("http://mare.ing.puc.cl/banco/"+url_req)
      req = Net::HTTP::Put.new(url.to_s,initheader = {'Content-Type' =>'application/json'})
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
 
  def getInfoFromJSON(input,field)
    @data=Array.new
      JSON.parse(input).each do |data_value|
        @data.push(data_value[field])
      end
 
    return @data[0]
  end
 
  def ApiProducirMp(sku, num_batch)
    #sku = params[:sku].to_i
    #num_batch = params[:num_batch].to_i
   
 
    if sku!=7 && sku!=15
      puts "Nosotros no producimos ese producto"
    else
      puts "Vas a producir el sku: "+sku.to_s+" con "+num_batch.to_s+" número de batchs"
      costo_unitario=0
      cant_sku=0
 
      if sku==7
        cant_sku=1000
        costo_unitario=941*cant_sku
      elsif sku==15
        cant_sku=480
        costo_unitario=969*cant_sku
      end
 
      costo_prod=costo_unitario*num_batch
      cant_prod=num_batch*cant_sku
      puts "El costo unitario por batch es "+costo_unitario.to_s+" y el costo total de esta producción es "+costo_prod.to_s
 
      url_bodega = "http://integracion-2016-dev.herokuapp.com/bodega/"
      url_banco = "http://mare.ing.puc.cl/banco/"
 
 
      #@response = getBancoJSONData("cuenta/571262c3a980ba030058ab65")
     #@response = getBancoJSONData("cuenta/571262c3a980ba030058ab64")
      saldo = getInfoFromJSON(@response,"saldo")
     
      puts saldo
 
      if saldo >= costo_prod
        @response2 = getBodegaJSONData("fabrica/getCuenta","")
        cuenta_id = JSON.parse(@response2)["cuentaId"]
        puts cuenta_id
 
        aux_hash={:monto=>costo_prod, :origen=>"571262c3a980ba030058ab65", :destino=>cuenta_id}
        jsonbody = JSON.generate(aux_hash)
        puts jsonbody
 
        @response3 = putBancoJSONData('trx',jsonbody)
        puts @response3
        if @response3=="error" || @response3=="request_error"
          puts "TRX error, can't continue"
        else
          trx_id = JSON.parse(@response3)["_id"]
          puts trx_id
 
          aux_hash2 = {:sku=>sku.to_s, :trxId=>trx_id, :cantidad=>cant_prod}
          jsonbody2 = JSON.generate(aux_hash2)
 
          @response4 = putBodegaJSONData("fabrica/fabricar",jsonbody2,sku.to_s+cant_prod.to_s+trx_id)
          puts @response4
 
        end
      else
        puts "No hay saldo suficiente para producir"
      end
 

    end
  end

#TERMINAR MANDAR A COMPRAR MATERIAS PRIMAS



def cantidad_sku_almacen
	@dev = "/Users/eczerega/Desktop/taleer/appname/jobs/up2.txt"
	#@dev = "/home/administrator/appname/jobs/up2.txt"
	sku_leche = "7"
	sku_avena = "15"
	results = File.open(@dev, "a")
	almacenes = get_almacenes_id
	almacenes.each do |almaceniddata|
		almacen_split=almaceniddata.split(';')
		almacenid=almacen_split[0]
		es_despacho= almacen_split[2]
		es_pulmon= almacen_split[3]
		es_recepcion= almacen_split[4]
		#if true
		if es_recepcion == "false" && es_pulmon == "false" && es_despacho == "false"
			cantidad_maxima = almacen_split[1].to_i/5
			@hash= generateHash('GET'+almacenid)
			#puts (1000/999).to_s	
			@hashi = 'INTEGRACION grupo12:'+ @hash
			url = URI.parse("http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock?almacenId="+almacenid)
			req = Net::HTTP::Get.new(url.to_s)
			req['Authorization'] = @hashi
			res = Net::HTTP.start(url.host, url.port) {|http|
			  http.request(req)
			}
			productos = JSON.parse(res.body)
			productos.each do |producto|
				#puts "Almacen: " +almacenid.to_s+ " Tipo: " + " Total espacio: "+ almacen_split[1] + " Cantidad maxima: "+ cantidad_maxima.to_s + " SKU: "+producto["_id"].to_s+" Total: "+producto["total"].to_s
				if producto["total"].to_i < cantidad_maxima.to_i
					cantidad_producir = cantidad_maxima.to_i - producto["total"].to_i

					if producto["_id"].to_s == sku_leche || producto["_id"].to_s == sku_avena

					puts 'MANDAR A HACER MATERIA PRIMA '+ cantidad_producir.to_s + " DE " + producto["_id"].to_s + "\n"
					results << 'MANDAR A HACER MATERIA PRIMA'+ cantidad_producir.to_s + " DE " + producto["_id"].to_s + "\n"

					else
					puts 'MANDAR A HACER PROD SECUNDARIO '+ cantidad_producir.to_s + " DE " + producto["_id"].to_s + "\n"
					results << 'MANDAR A HACER PROD SECUNDARIO'+ cantidad_producir.to_s + " DE " + producto["_id"].to_s + "\n"						
					end
				end
			end
		end
	end
	results << "SALTO DE LINEA \n"
	results.close
end


cantidad_sku_almacen
#ApiProducirMp(7, 1)
#results = File.open("/Users/eczerega/Desktop/taleer/appname/jobs/stock.txt", "a")
#results << got_stock_internal('30').to_s
#results.close





