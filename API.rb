require 'rubygems'
require 'rest-client'
require 'base64'
require 'cgi'
require 'openssl'
require 'hmac-sha1'
require 'json'
require 'net/http'
#require 'digest/hmac'



#permite generar el hash para las distintas autorizaciones, lo retorna
def generateHash (contenidoSignature)
    encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
    return encoded_string
end

def getJSONData(url_req)
    @hashi = 'INTEGRACION grupo12:'+generateHash('GET').to_s
    url = URI.parse(url_req)
    req = Net::HTTP::Get.new(url.to_s)
    req['Authorization'] = @hashi
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    return res.body
end

def putJSONData(url_req, params)
    @hashi = 'INTEGRACION grupo12:'+generateHash('PUT').to_s
    puts @hashi
    url = URI.parse(url_req)
    req = Net::HTTP::Put.new(url.to_s)
    req['Authorization'] = @hashi
    req['Params'] = params
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    return res.body   
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

def ApiProducirMp(sku, num_batch)

  if sku!=7 && sku!=15
    puts "Nosotros no producimos ese producto"
  else
    puts "Vas a producir el sku: "+sku.to_s+" con "+num_batch.to_s+" número de batchs"
    costo_unitario=0

    if sku==7
      costo_unitario=941
    elsif sku==15
      costo_unitario=969
    end

    costo_prod=costo_unitario*num_batch
    puts "El costo unitario por batch es "+costo_unitario.to_s+" y el costo total de esta producción es "+costo_prod.to_s

    @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET').to_s
    @hashi_put = 'INTEGRACION grupo12:'+generateHash('PUT').to_s
    #puts @hashi_get.to_s
    url_bodega = "http://integracion-2016-dev.herokuapp.com/bodega/"
    url_banco = "http://mare.ing.puc.cl/banco/"

    @response = getJSONData(url_banco+"cuenta/571262c3a980ba030058ab65")

    saldo = getInfoFromJSON(@response,"saldo")
    puts saldo

    if saldo >= costo_prod
      @response2 = getJSONData(url_bodega+"fabrica/getCuenta")
      puts @response2

      cuenta_id = getInfoFromJSON(@response2,"cuenta_id");
      puts cuenta_id

      #puts RestClient.put url_banco+"trx", {:Authorization => @hashi_get, :Params => {"monto":costo_prod,"origen":"571262c3a980ba030058ab65","destino":"cuenta_id"}}
      #response3 = JSON.parse RestClient.put url_banco+"trx", {:Authorization => @hashi_get, :Params => {"monto":costo_prod,"origen":"571262c3a980ba030058ab65","destino":"cuenta_id"}}
    else
      puts "No hay saldo suficiente para producir"
    end 
  end

  

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
puts ApiProducirMp(7,1)
#puts stock('47',86)

