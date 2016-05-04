class AlamacenesController < ApplicationController
  before_action :set_alamacene, only: [:show, :edit, :update, :destroy]

  # GET /alamacenes
  # GET /alamacenes.json
  def index
    @alamacenes = Alamacene.all
  end

  # GET /alamacenes/1
  # GET /alamacenes/1.json
  def show
  end

  # GET /alamacenes/new
  def new
    @alamacene = Alamacene.new
  end

  # GET /alamacenes/1/edit
  def edit
  end

  # POST /alamacenes
  # POST /alamacenes.json
  def create
    @alamacene = Alamacene.new(alamacene_params)

    respond_to do |format|
      if @alamacene.save
        format.html { redirect_to @alamacene, notice: 'Alamacene was successfully created.' }
        format.json { render :show, status: :created, location: @alamacene }
      else
        format.html { render :new }
        format.json { render json: @alamacene.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /alamacenes/1
  # PATCH/PUT /alamacenes/1.json
  def update
    respond_to do |format|
      if @alamacene.update(alamacene_params)
        format.html { redirect_to @alamacene, notice: 'Alamacene was successfully updated.' }
        format.json { render :show, status: :ok, location: @alamacene }
      else
        format.html { render :edit }
        format.json { render json: @alamacene.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alamacenes/1
  # DELETE /alamacenes/1.json
  def destroy
    @alamacene.destroy
    respond_to do |format|
      format.html { redirect_to alamacenes_url, notice: 'Alamacene was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_alamacene
      @alamacene = Alamacene.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def alamacene_params
      params.require(:alamacene).permit(:almacenid, :tamano)
    end
end
