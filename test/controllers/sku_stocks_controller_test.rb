require 'test_helper'

class SkuStocksControllerTest < ActionController::TestCase
  setup do
    @sku_stock = sku_stocks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sku_stocks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sku_stock" do
    assert_difference('SkuStock.count') do
      post :create, sku_stock: { SKU: @sku_stock.SKU, stock: @sku_stock.stock }
    end

    assert_redirected_to sku_stock_path(assigns(:sku_stock))
  end

  test "should show sku_stock" do
    get :show, id: @sku_stock
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sku_stock
    assert_response :success
  end

  test "should update sku_stock" do
    patch :update, id: @sku_stock, sku_stock: { SKU: @sku_stock.SKU, stock: @sku_stock.stock }
    assert_redirected_to sku_stock_path(assigns(:sku_stock))
  end

  test "should destroy sku_stock" do
    assert_difference('SkuStock.count', -1) do
      delete :destroy, id: @sku_stock
    end

    assert_redirected_to sku_stocks_path
  end
end
