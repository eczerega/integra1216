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
    url = URI("http://mare.ing.puc.cl/facturas/")
  http = Net::HTTP.new(url.host, url.port)

  request = Net::HTTP::Put.new(url)
  request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
  request["authorization"] = 'INTEGRACION grupo12:'+generateHash('PUT'+id_oc).to_s
  request["cache-control"] = 'no-cache'
  request["postman-token"] = '09915d89-9455-3f0c-6eb1-407f29b4286d'
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

  def enviar_factura(id_factura, id_cliente)
    @response = JSON.parse RestClient.post "http://integra"+id_cliente+".ing.puc.cl/api/facturas/recibir/.:"+id_factura
    return @response
  end


#puts aceptar_orden("57265e0f006ba10300bc4390")
puts 'INTEGRACION grupo12:'+generateHash('GET'+'57281872c1ff9b030001a2e4').to_s
#puts stock('47',86)

