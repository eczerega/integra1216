
url_bodega="http://integracion-2016-dev.herokuapp.com/bodega"



class ProduccionsController < ApplicationController
  before_action :set_produccion, only: [:show, :edit, :update, :destroy]
    layout false

          #permite generar el hash para las distintas autorizaciones, lo retorna
  def generateHash (contenidoSignature)
      encoded_string = Base64.encode64(OpenSSL::HMAC.digest('sha1','akVf0btGVOwkhvI', contenidoSignature)).chomp
      return encoded_string
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

  def getInfoFromJSON(input,field)
    @data=Array.new
      JSON.parse(input).each do |data_value|
        @data.push(data_value[field])
      end

    return @data[0]
  end

  def ApiProducirMp()
    sku = params[:sku].to_i
    num_batch = params[:num_batch].to_i
    

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

      if saldo <= costo_prod
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

      respond_to do |format|
        format.json {  }
      end
    end
  end
  # GET /produccions
  # GET /produccions.json
  def index
    @produccions = Produccion.all
  end

  # GET /produccions/1
  # GET /produccions/1.json
  def show
  end

  # GET /produccions/new
  def new
    @produccion = Produccion.new

    #@hashi = 'INTEGRACION grupo12:'+generateHash('GET').to_s
    #response = JSON.parse RestClient.get url_bodega+"fabrica/getCuentaFabrica", {:Authorization => @hashi}

    puts response
  end

  # GET /produccions/1/edit
  def edit
  end

  # POST /produccions
  # POST /produccions.json
  def create
    @produccion = Produccion.new(produccion_params)

    respond_to do |format|
      if @produccion.save
        format.html { redirect_to @produccion, notice: 'Produccion was successfully created.' }
        format.json { render :show, status: :created, location: @produccion }
      else
        format.html { render :new }
        format.json { render json: @produccion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /produccions/1
  # PATCH/PUT /produccions/1.json
  def update
    respond_to do |format|
      if @produccion.update(produccion_params)
        format.html { redirect_to @produccion, notice: 'Produccion was successfully updated.' }
        format.json { render :show, status: :ok, location: @produccion }
      else
        format.html { render :edit }
        format.json { render json: @produccion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /produccions/1
  # DELETE /produccions/1.json
  def destroy
    @produccion.destroy
    respond_to do |format|
      format.html { redirect_to produccions_url, notice: 'Produccion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_produccion
      @produccion = Produccion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def produccion_params
      params.require(:produccion).permit(:id_dev, :created_at_dev, :fecha_termino)
    end
end



