class FacturaOcsController < ApplicationController
  before_action :set_factura_oc, only: [:update]
layout false
  # GET /factura_ocs
  # GET /factura_ocs.json
  def index
    @factura_ocs = FacturaOc.all
  end

  # GET /factura_ocs/1
  # GET /factura_ocs/1.json
  def show
  end

  # GET /factura_ocs/new
  def new
    @factura_oc = FacturaOc.new
  end

  # GET /factura_ocs/1/edit
  def edit
  end

  # POST /factura_ocs
  # POST /factura_ocs.json
  def create
    @factura_oc = FacturaOc.new(factura_oc_params)

    respond_to do |format|
      if @factura_oc.save
        format.html { redirect_to @factura_oc, notice: 'Factura oc was successfully created.' }
        format.json { render :show, status: :created, location: @factura_oc }
      else
        format.html { render :new }
        format.json { render json: @factura_oc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /factura_ocs/1
  # PATCH/PUT /factura_ocs/1.json
  def update
    respond_to do |format|
      if @factura_oc.update(factura_oc_params)
        format.html { redirect_to @factura_oc, notice: 'Factura oc was successfully updated.' }
        format.json { render :show, status: :ok, location: @factura_oc }
      else
        format.html { render :edit }
        format.json { render json: @factura_oc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /factura_ocs/1
  # DELETE /factura_ocs/1.json
  def destroy
    @factura_oc.destroy
    respond_to do |format|
      format.html { redirect_to factura_ocs_url, notice: 'Factura oc was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factura_oc
      @factura_oc = FacturaOc.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_oc_params
      params.require(:factura_oc).permit(:factura_id, :oc_id, :estado)
    end
end
