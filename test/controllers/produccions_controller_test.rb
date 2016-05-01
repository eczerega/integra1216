require 'test_helper'

class ProduccionsControllerTest < ActionController::TestCase
  setup do
    @produccion = produccions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:produccions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create produccion" do
    assert_difference('Produccion.count') do
      post :create, produccion: { created_at_dev: @produccion.created_at_dev, fecha_termino: @produccion.fecha_termino, id_dev: @produccion.id_dev }
    end

    assert_redirected_to produccion_path(assigns(:produccion))
  end

  test "should show produccion" do
    get :show, id: @produccion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @produccion
    assert_response :success
  end

  test "should update produccion" do
    patch :update, id: @produccion, produccion: { created_at_dev: @produccion.created_at_dev, fecha_termino: @produccion.fecha_termino, id_dev: @produccion.id_dev }
    assert_redirected_to produccion_path(assigns(:produccion))
  end

  test "should destroy produccion" do
    assert_difference('Produccion.count', -1) do
      delete :destroy, id: @produccion
    end

    assert_redirected_to produccions_path
  end
end
