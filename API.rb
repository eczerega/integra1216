require 'rubygems'
require 'rest-client'
require 'base64'
require 'cgi'
require 'openssl'
require 'hmac-sha1'
require 'json'
require 'net/http'
require 'time'
#require 'digest/hmac'



#permite generar el hash para las distintas autorizaciones, lo retorna
def generateHash (contenidoSignature)
    encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
    return encoded_string
end

def getJSONData(url_req, param_string)
    @hashi = 'INTEGRACION grupo12:'+generateHash('GET'+param_string).to_s
    url = URI.parse("http://mare.ing.puc.cl/banco/"+url_req)
    req = Net::HTTP::Get.new(url.to_s)
    req['Authorization'] = @hashi
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    return res.body
end

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

def ApiBodegaGetAlmacenes(request)
  @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET'+request).to_s
  puts @hashi_get.to_s
  response = JSON.parse RestClient.get "http://integracion-2016-dev.herokuapp.com/bodega/almacenes", {:Authorization => @hashi_get}
  #puts response
  return response
end

def ApiBodegaGetSku(request)
  @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET'+request).to_s
  #puts @hashi_get.to_s
  response = JSON.parse RestClient.get "http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock?almacenId="+request, {:Authorization => @hashi_get}
  #puts response
  return response
end

def getInfoFromJSON(input,field)
  @data=Array.new
    JSON.parse(input).each do |data_value|
      @data.push(data_value[field])
    end

  return @data[0]
end

def producir_mp(sku, num_batch)
  sku = params[:sku]
  num_batch = params[:num_batch]
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


    @response = getBancoJSONData("cuenta/571262c3a980ba030058ab65")
    saldo = getInfoFromJSON(@response,"saldo")
    
    puts saldo

    # if saldo >= costo_prod
    #   @response2 = getBodegaJSONData("fabrica/getCuenta","")
    #   cuenta_id = JSON.parse(@response2)["cuentaId"]
    #   puts cuenta_id

    #   aux_hash={:monto=>costo_prod, :origen=>"571262c3a980ba030058ab65", :destino=>cuenta_id}
    #   jsonbody = JSON.generate(aux_hash)
    #   puts jsonbody

    #   #@response3 = putBancoJSONData('trx',jsonbody)
    #   #puts @response3
    #   if @response3=="error" || @response3=="request_error"
    #     puts "TRX error, can't continue"
    #   else
    #     #trx_id = JSON.parse(@response3)["_id"]
    #     trx_id = "572778bbc1ff9b0300017d37"
    #     puts trx_id

    #     aux_hash2 = {:sku=>sku.to_s, :trxId=>trx_id, :cantidad=>cant_prod}
    #     jsonbody2 = JSON.generate(aux_hash2)

    #     @response4 = putBodegaJSONData("fabrica/fabricar",jsonbody2,sku.to_s+cant_prod.to_s+trx_id)
    #     puts @response4

    #   end
    # else
    #   puts "No hay saldo suficiente para producir"
    # end 
  end
end


def comprar_producto(sku,cantidad)
  hola = Tiempo.where(SKU:sku)

  puts hola
end

def fecha_UNIX_restar(horas)
  fecha_entrega = (DateTime.now-horas.hours).strftime('%Q')
  puts fecha_entrega
end

def fecha_UNIX_sumar(horas)
  fecha_entrega = (DateTime.now+horas.hours).strftime('%Q')
  puts fecha_entrega
end
=begin
def stock(sku, cantidad)
  data = ApiBodegaGetAlmacenes('')
  @almacenes = []
  data.each do |almacen|
    @almacenes << almacen["_id"]
  end
  contador = 0
  @almacenes.each do |almacen|
  #puts 'produtos de almacen: '+almacen
     @productos = []
     bodega = ApiBodegaGetSku(almacen)
     bodega.each do |producto|
       #puts producto
       if producto["_id"].to_s == sku.to_s
         contador +=  producto["total"].to_i
       end
     end

  end
  #puts contador
  if contador >= cantidad
    return true
  else
    return false
  end

end
=end
#puts ApiBodegaGetAlmacenes('')
#puts ApiProducirMp(7,1)
#puts generateHash("PUT914571262c3a980ba030058ab65571262aea980ba030058a5d8")
#puts stock('47',86)
puts fecha_UNIX_restar(24)
#comprar_producto(1,1)
