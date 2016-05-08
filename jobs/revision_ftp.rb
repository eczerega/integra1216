require 'net/ssh'
require 'net/sftp'
require 'nokogiri'
require 'uri'
require 'net/http'
require 'json'
require 'pg'

CONTENT_SERVER_DOMAIN_NAME = "mare.ing.puc.cl"
CONTENT_SERVER_FTP_LOGIN = "integra12"
CONTENT_SERVER_FTP_PASSWORD = "qNvdKs48"

#----------------DESPACHAR---------------------
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

  def despachar(id_oc, sku, cantidad, producto, precio)

    price = precio.to_s
    direccion = "internacional"
    puts "--------------\nDATOS DESPACHO\n"
    puts "PRODUCTID"+producto.to_s + "\nPRECIO"+ precio.to_s + "\nIDOC" + id_oc.to_s + "\n"
    puts generateHash('DELETE'+ producto + direccion + price + id_oc).to_s
    puts "\n-----------------\n"

    url = URI("http://integracion-2016-dev.herokuapp.com/bodega/stock")

    http = Net::HTTP.new(url.host, url.port)

    request = Net::HTTP::Delete.new(url)
    request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
    request["authorization"] = 'INTEGRACION grupo12:'+generateHash('DELETE'+ producto + direccion + price + id_oc).to_s
    request["cache-control"] = 'no-cache'
    request.body = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"precio\"\r\n\r\n"+price+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"direccion\"\r\n\r\n"+direccion+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"oc\"\r\n\r\n"+id_oc+"\r\n-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"productoId\"\r\n\r\n"+producto+"\r\n-----011000010111000001101001--"

    response = http.request(request)
    puts response.body
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

  def moverProductos(id_oc, almacenId, sku, cantidad, faltante, precio)
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

        puts "despachando desde " + almacenId + " hacia internacional ..."
        despachar(id_oc, sku, cantidad, @producto_a_mover, precio)
        faltante -= 1

        if faltante == 0
            return faltante
        end
        
      end
    return faltante
  end

    def preparar_despacho(id_oc, sku, cantidad, precio)

      #571262aba980ba030058a5c7 despacho
      #571262aa980ba030058a5c6 recepcion
      #571262aba980ba030058a5d7 pulmon
      #571262aba980ba030058a5c8 otra
      #571262aba980ba030058a5d6 otra
      almacen_despacho = '571262aba980ba030058a5c7'
      stock_en_despacho = contarProductos(almacen_despacho, sku)
      if cantidad <= stock_en_despacho
        puts "listos para despachar"
        faltante = moverProductos(id_oc, almacen_despacho, sku, cantidad, cantidad, precio)
        tablasku = SkuStock.find_by(SKU: sku)
        tablasku.stock -= cantidad
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
          faltante = moverProductos(id_oc, almacen_despacho, sku, cantidad, faltante, precio)
          @mis_almacenes.each do |almacen|
            faltante = moverProductos(id_oc, almacen, sku, cantidad, faltante, precio)
            puts 'faltan ' + faltante.to_s  
            if faltante == 0
              break
            end
          end
          puts "despachamos!"
          tablasku = SkuStock.find_by(SKU: sku)
          tablasku.stock -= cantidad
          ###despachar()
        else
          puts "NO SE PUEDE DESPACHAR"
          ###NO SE PUEDE DESPACHAR
        end
      end 
    end

#----------------END DESPACHAR--------------------

#HASH PARA DESARROLLO
def generateHash (contenidoSignature)
      encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
      return encoded_string
    end

def contarTotal(sku)
  #url = URI("http://integracion-2016-prod.herokuapp.com/bodega/almacenes")
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
  #poblar base de datos
  return @factura_id
end

def rechazar_orden(id_oc)
  #PRODUCCION URI("http://moto.ing.puc.cl/oc/rechazar"+id_oc)
  url = URI("http://mare.ing.puc.cl/oc/rechazar/"+id_oc)

  http = Net::HTTP.new(url.host, url.port)

  request = Net::HTTP::Post.new(url)
  request["content-type"] = 'multipart/form-data; boundary=---011000010111000001101001'
  request["cache-control"] = 'no-cache'
  request["postman-token"] = 'b7f61248-cd1d-f976-6728-c812c73dcd87'
  request.body = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"rechazo\"\r\n\r\nFalta de stock\r\n-----011000010111000001101001--"

  response = http.request(request)
  puts response.read_body
end

def precio_db(sku)

  conn = PG::Connection.open(:dbname => 'appname_development')
  res = conn.exec_params('SELECT "Precio_Unitario" FROM precios WHERE "SKU"=\''+sku+'\'')
  conn.close
  return res.getvalue(0,0).to_i
end

def almacen_cliente(cliente_id, ambiente)  
  conn = PG::Connection.open(:dbname => 'appname_development')
  res = conn.exec_params('SELECT "id_almacen" FROM info_grupos WHERE id_grupo = "'+cliente_id+'" AND ambiente="'+ambiente+'"')
  conn.close
  return res.getvalue(0,0).to_i
end

def getOCJSON(id_oc)
  url = URI("http://mare.ing.puc.cl/oc/obtener/"+id_oc)

  http = Net::HTTP.new(url.host, url.port)

  request2 = Net::HTTP::Get.new(url)
  request2["cache-control"] = 'no-cache'

  @oc = http.request(request2)
  @oc_array = JSON.parse(@oc.body)

  @oc_json = JSON.parse(@oc_array[0].to_json)
  puts @oc_json
  return @oc_json
end

def enviar_factura(id_factura, id_cliente)
    
    num_grupo = InfoGrupo.find_by(id_grupo: id_cliente).num_grupo

    url = URI("http://integra"+num_grupo+".ing.puc.cl/api/facturas/recibir/"+id_factura)

  http = Net::HTTP.new(url.host, url.port)

  request = Net::HTTP::Get.new(url)
  request["cache-control"] = 'no-cache'

  @response = http.request(request)
  @response_json = JSON.parse(@response.body)
  puts @response_json
  return @response_json
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



Net::SFTP.start(CONTENT_SERVER_DOMAIN_NAME, CONTENT_SERVER_FTP_LOGIN , :password => CONTENT_SERVER_FTP_PASSWORD) do |sftp|
@i=0
sftp.dir.entries('/pedidos').each do |remote_file|
    if  remote_file.name != '.' && remote_file.name != '..' && @i<2
      #results = File.open("./pedidos/"+remote_file.name, "a")
      file_data = sftp.download!('/pedidos' + '/' + remote_file.name)
      puts file_data
      @doc = Nokogiri::XML(file_data)
      @oc_id = @doc.search('id').text
      @json_oc = getOCJSON(@oc_id)
      @oc_precio = @json_oc["precioUnitario"].to_i
      @oc_sku = @doc.search('sku').text
      @oc_cantidad = @doc.search('qty').text.to_i
      @precio_unitario = precio_db(@oc_sku)

      if @oc_sku.to_i<contarTotal(@oc_sku) && @oc_precio > @precio_unitario
        puts "vender"
        puts aceptar_orden(@oc_id)
        @id_factura = generar_factura(@oc_id)
        puts "\nID FACTURA:"+@id_factura+"\n"
        @id_cliente = @json_oc["cliente"]
        #@response_factura = @enviar_factura(@id_factura, @id_cliente)
        #puts @response_factura

        #@oc_cantidad = @json_oc["cantidad"]
        #@almacen_destino = almacen_cliente(@id_cliente, "desarrollo")
        preparar_despacho(@oc_id.to_s, @oc_sku, @oc_cantidad, @oc_precio)
      else
        puts "NO HAY SUFICIENTE STOCK"
      end
        #preparar_despachon
      #else
       # rechazar_orden(id_oc)
      #end

      #puts id
      @i+=1
    end
  end
end
