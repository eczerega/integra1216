class OcRecibidasController < ApplicationController
  before_action :set_oc_recibida, only: [:show, :edit, :update, :destroy]

    layout false
  # GET /oc_recibidas
  # GET /oc_recibidas.json
  def index
    @oc_recibidas = OcRecibida.all
  end

  # GET /oc_recibidas/1
  # GET /oc_recibidas/1.json
  def show
  end

  # GET /oc_recibidas/new
  def new
    @oc_recibida = OcRecibida.new
  end

  # GET /oc_recibidas/1/edit
  def edit
  end

  # POST /oc_recibidas
  # POST /oc_recibidas.json
  def create
    @oc_recibida = OcRecibida.new(oc_recibida_params)

    respond_to do |format|
      if @oc_recibida.save
        format.html { redirect_to @oc_recibida, notice: 'Oc recibida was successfully created.' }
        format.json { render :show, status: :created, location: @oc_recibida }
      else
        format.html { render :new }
        format.json { render json: @oc_recibida.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /oc_recibidas/1
  # PATCH/PUT /oc_recibidas/1.json
  def update
    respond_to do |format|
      if @oc_recibida.update(oc_recibida_params)
        format.html { redirect_to @oc_recibida, notice: 'Oc recibida was successfully updated.' }
        format.json { render :show, status: :ok, location: @oc_recibida }
      else
        format.html { render :edit }
        format.json { render json: @oc_recibida.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /oc_recibidas/1
  # DELETE /oc_recibidas/1.json
  def destroy
    @oc_recibida.destroy
    respond_to do |format|
      format.html { redirect_to oc_recibidas_url, notice: 'Oc recibida was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_oc_recibida
      @oc_recibida = OcRecibida.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def oc_recibida_params
      params.require(:oc_recibida).permit(:id_dev, :created_at_dev, :canal, :sku, :cantidad, :precio_unit, :entrega_at, :despacho_at, :estado, :rechazo, :anulacion, :notas, :id_factura_dev)
    end
end
