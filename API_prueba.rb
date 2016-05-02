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

def generar_factura(id_oc)
  @hashi_put = 'INTEGRACION grupo12:'+generateHash('PUT'+id_oc).to_s
  @response = JSON.parse RestClient.put "http://mare.ing.puc.cl/facturas/", {oc: id_oc}, {:Authorization => @hashi_get}
  @factura_id = @response["_id"]
  return @factura_id
end

def aceptar_orden(id_oc)
  @hashi_put = 'INTEGRACION grupo12:'+generateHash('POST'+id_oc).to_s
  @response = JSON.parse RestClient.post "http://mare.ing.puc.cl/oc/recepcionar/"+id_oc, {:Authorization => @hashi_get}
  return @response
end


puts generar_factura("57265e0f006ba10300bc4390")
#puts stock('47',86)

