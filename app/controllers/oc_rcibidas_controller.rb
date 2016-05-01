class OcRcibidasController < ApplicationController
  before_action :set_oc_rcibida, only: [:show, :edit, :update, :destroy]
    layout false
  # GET /oc_rcibidas
  # GET /oc_rcibidas.json
  def index
    @oc_rcibidas = OcRcibida.all
  end

  # GET /oc_rcibidas/1
  # GET /oc_rcibidas/1.json
  def show
  end

  # GET /oc_rcibidas/new
  def new
    @oc_rcibida = OcRcibida.new
  end

  # GET /oc_rcibidas/1/edit
  def edit
  end

  # POST /oc_rcibidas
  # POST /oc_rcibidas.json
  def create
    @oc_rcibida = OcRcibida.new(oc_rcibida_params)

    respond_to do |format|
      if @oc_rcibida.save
        format.html { redirect_to @oc_rcibida, notice: 'Oc rcibida was successfully created.' }
        format.json { render :show, status: :created, location: @oc_rcibida }
      else
        format.html { render :new }
        format.json { render json: @oc_rcibida.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /oc_rcibidas/1
  # PATCH/PUT /oc_rcibidas/1.json
  def update
    respond_to do |format|
      if @oc_rcibida.update(oc_rcibida_params)
        format.html { redirect_to @oc_rcibida, notice: 'Oc rcibida was successfully updated.' }
        format.json { render :show, status: :ok, location: @oc_rcibida }
      else
        format.html { render :edit }
        format.json { render json: @oc_rcibida.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /oc_rcibidas/1
  # DELETE /oc_rcibidas/1.json
  def destroy
    @oc_rcibida.destroy
    respond_to do |format|
      format.html { redirect_to oc_rcibidas_url, notice: 'Oc rcibida was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_oc_rcibida
      @oc_rcibida = OcRcibida.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def oc_rcibida_params
      params.require(:oc_rcibida).permit(:id_dev, :created_at_dev, :canal, :sku, :cantidad, :precio_unit, :entrega_at, :despacho_at, :estado, :rechazo, :anulacion, :notas, :id_factura_dev)
    end
end
