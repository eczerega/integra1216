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
    #url = URI("http://integra"+id_cliente+".ing.puc.cl/api/facturas/recibir/"+id_factura)
  url = URI("http://localhost:3000/api/facturas/recibir/"+id_factura)
  http = Net::HTTP.new(url.host, url.port)

  request = Net::HTTP::Get.new(url)
  request["cache-control"] = 'no-cache'
  @response = http.request(request)
  @response_json = JSON.parse(@response.body)
  puts @response_json
  return @response_json
  end

#puts (DateTime.now+5).strftime('%Q')
#enviar_factura("3",12)
#puts aceptar_orden("57265e0f006ba10300bc4390")
#puts 'INTEGRACION grupo12:'+generateHash('GET'+'57281872c1ff9b030001a2e4').to_s
#puts stock('47',86)
#puts preparar_despacho('5728488cc1ff9b030001a5c3', '7', 105)
#puts restaurar
#productoId = '5727b83afb10f70300bb82d8'
#precio = '1307'
#almacenId = '571262aaa980ba030058a147'
#oc = '5728e8999fda6e030047091d'
#puts 'INTEGRACION grupo12:'+generateHash('POST'+ productoId + almacenId).to_s













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
    request.body = "{\n    \"productoId\": \""+ producto +"\",\n    \"almacenId\": \""+ almacen_destino +"\",\n    \"oc\": \""+ id_oc +"\",\n    \"precio\": "+ price +"\n}"
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

  def traspaso_interno(almacenOrigen, almacenDestino, sku, qty)
      url = URI("http://integracion-2016-dev.herokuapp.com/bodega/stock?almacenId=" + almacenOrigen + "&sku=" + sku + "&limit=199" )
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      @hashi_get = 'INTEGRACION grupo12:'+generateHash('GET'+ almacenOrigen + sku).to_s
      request["authorization"] = @hashi_get 
      request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
      request["cache-control"] = 'no-cache'
      request["postman-token"] = '2d38d414-b654-7ea2-d7f2-e1379efa0526'
      response = http.request(request)
      count = 0
      JSON.parse(response.body).each do |line|
        @producto_a_mover = line["_id"].to_s
        puts @producto_a_mover
        puts "moviendo a otra bodega"
        mover_a_bodega(@producto_a_mover, almacenDestino)  
        puts "despachando..."
        count += 1
        if count == qty
          break
        end
      end
  end

#productoId = '5727b83afb10f70300bb82d8'
precio = 941
almacenId = '571262aba980ba030058a5c6'
oc = '5728e3479fda6e0300470909'
sku = '7'
cantidad = 2
#precio = 941
#traspaso_interno('571262aba980ba030058a5c6', '571262aba980ba030058a5c8', sku, 155)
preparar_despacho(oc, sku, cantidad, precio, almacenId)