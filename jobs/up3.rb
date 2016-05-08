
#HASH PARA DESARROLLO
def generateHash (contenidoSignature)
      encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','Cfs%agh:i#B8&f6', contenidoSignature)).chomp
      return encoded_string
    end

def contarTotal(sku)
  #url = URI("http://integracion-2016-prod.herokuapp.com/bodega/almacenes")
  url = URI("http://integracion-2016-prod.herokuapp.com/bodega/almacenes")
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
  url = URI("http://moto.ing.puc.cl/facturas/")
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
  url = URI("http://moto.ing.puc.cl/oc/rechazar/"+id_oc)

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
  url = URI("http://moto.ing.puc.cl/oc/obtener/"+id_oc)

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
    url = URI("http://moto.ing.puc.cl/oc/recepcionar/"+id_oc)
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