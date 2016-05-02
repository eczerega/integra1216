class SkuStocksController < ApplicationController
  before_action :set_sku_stock, only: [:show, :edit, :update, :destroy]

  # GET /sku_stocks
  # GET /sku_stocks.json
  def index
    @sku_stocks = SkuStock.all
  end

  # GET /sku_stocks/1
  # GET /sku_stocks/1.json
  def show
  end

  # GET /sku_stocks/new
  def new
    @sku_stock = SkuStock.new
  end

  # GET /sku_stocks/1/edit
  def edit
  end

  # POST /sku_stocks
  # POST /sku_stocks.json
  def create
    @sku_stock = SkuStock.new(sku_stock_params)

    respond_to do |format|
      if @sku_stock.save
        format.html { redirect_to @sku_stock, notice: 'Sku stock was successfully created.' }
        format.json { render :show, status: :created, location: @sku_stock }
      else
        format.html { render :new }
        format.json { render json: @sku_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sku_stocks/1
  # PATCH/PUT /sku_stocks/1.json
  def update
    respond_to do |format|
      if @sku_stock.update(sku_stock_params)
        format.html { redirect_to @sku_stock, notice: 'Sku stock was successfully updated.' }
        format.json { render :show, status: :ok, location: @sku_stock }
      else
        format.html { render :edit }
        format.json { render json: @sku_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sku_stocks/1
  # DELETE /sku_stocks/1.json
  def destroy
    @sku_stock.destroy
    respond_to do |format|
      format.html { redirect_to sku_stocks_url, notice: 'Sku stock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sku_stock
      @sku_stock = SkuStock.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sku_stock_params
      params.require(:sku_stock).permit(:SKU, :stock)
    end
end
