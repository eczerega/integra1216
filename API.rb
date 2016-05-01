require 'rubygems'
require 'rest-client'
require 'base64'
require 'cgi'
require 'openssl'
require 'hmac-sha1'
#require 'digest/hmac'


#permite generar el hash para las distintas autorizaciones, lo retorna
def generateHash (contenidoSignature)
  return Base64.encode64((HMAC::SHA1.new('akVf0btGVOwkhvI') << contenidoSignature).digest).strip
end


def ApiBodegaGetAlmacenes(request)
  @hashi = 'INTEGRACION grupo12:'+generateHash('GET'+request).to_s
  puts @hashi.to_s
  response = JSON.parse RestClient.get "http://integracion-2016-dev.herokuapp.com/bodega/almacenes", {:Authorization => @hashi}
  #puts response
  return response
end

def ApiBodegaGetSku(request)
  @hashi = 'INTEGRACION grupo12:'+generateHash('GET'+request).to_s
  #puts @hashi.to_s
  response = JSON.parse RestClient.get "http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock?almacenId="+request, {:Authorization => @hashi}
  #puts response
  return response
end


begin
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
  puts contador
  if contador >= cantidad
    return true
  else
    return false
  end

end
end
puts ApiBodegaGetAlmacenes('')
puts stock('51',86)

