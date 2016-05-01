class TiemposController < ApplicationController
  before_action :set_tiempo, only: [:show, :edit, :update, :destroy]

  # GET /tiempos
  # GET /tiempos.json
  def index
    @tiempos = Tiempo.all
  end

  # GET /tiempos/1
  # GET /tiempos/1.json
  def show
  end

  # GET /tiempos/new
  def new
    @tiempo = Tiempo.new
  end

  # GET /tiempos/1/edit
  def edit
  end

  # POST /tiempos
  # POST /tiempos.json
  def create
    @tiempo = Tiempo.new(tiempo_params)

    respond_to do |format|
      if @tiempo.save
        format.html { redirect_to @tiempo, notice: 'Tiempo was successfully created.' }
        format.json { render :show, status: :created, location: @tiempo }
      else
        format.html { render :new }
        format.json { render json: @tiempo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tiempos/1
  # PATCH/PUT /tiempos/1.json
  def update
    respond_to do |format|
      if @tiempo.update(tiempo_params)
        format.html { redirect_to @tiempo, notice: 'Tiempo was successfully updated.' }
        format.json { render :show, status: :ok, location: @tiempo }
      else
        format.html { render :edit }
        format.json { render json: @tiempo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tiempos/1
  # DELETE /tiempos/1.json
  def destroy
    @tiempo.destroy
    respond_to do |format|
      format.html { redirect_to tiempos_url, notice: 'Tiempo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tiempo
      @tiempo = Tiempo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tiempo_params
      params.require(:tiempo).permit(:SKU, :Descripción, :Tipo, :Grupo_Proyecto, :Unidades, :Costo_produccion_unitario, :Lote_Produccion, :Tiempo_Medio_Producción)
    end
end
