class CostosController < ApplicationController
  before_action :set_costo, only: [:show, :edit, :update, :destroy]
    layout false
  # GET /costos
  # GET /costos.json
  def index
    @costos = Costo.all
  end

  # GET /costos/1
  # GET /costos/1.json
  def show
  end

  # GET /costos/new
  def new
    @costo = Costo.new
  end

  # GET /costos/1/edit
  def edit
  end

  # POST /costos
  # POST /costos.json
  def create
    @costo = Costo.new(costo_params)

    respond_to do |format|
      if @costo.save
        format.html { redirect_to @costo, notice: 'Costo was successfully created.' }
        format.json { render :show, status: :created, location: @costo }
      else
        format.html { render :new }
        format.json { render json: @costo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /costos/1
  # PATCH/PUT /costos/1.json
  def update
    respond_to do |format|
      if @costo.update(costo_params)
        format.html { redirect_to @costo, notice: 'Costo was successfully updated.' }
        format.json { render :show, status: :ok, location: @costo }
      else
        format.html { render :edit }
        format.json { render json: @costo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /costos/1
  # DELETE /costos/1.json
  def destroy
    @costo.destroy
    respond_to do |format|
      format.html { redirect_to costos_url, notice: 'Costo was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_costo
      @costo = Costo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def costo_params
      params.require(:costo).permit(:SKU, :Descripcion, :Lote, :Unidad, :SKU_Ingrediente, :Ingrediente, :Requerimiento, :Unidad, :Ingrediente, :Precio_Ingrediente)
    end
end
