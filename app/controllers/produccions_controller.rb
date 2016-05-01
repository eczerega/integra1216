
url_bodega="http://integracion-2016-dev.herokuapp.com/bodega"

#permite generar el hash para las distintas autorizaciones, lo retorna
def generateHash (contenidoSignature)
  return Base64.encode64((HMAC::SHA1.new('akVf0btGVOwkhvI') << contenidoSignature).digest).strip
end

class ProduccionsController < ApplicationController
  before_action :set_produccion, only: [:show, :edit, :update, :destroy]
    layout false


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
