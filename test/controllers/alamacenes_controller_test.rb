require 'test_helper'

class AlamacenesControllerTest < ActionController::TestCase
  setup do
    @alamacene = alamacenes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:alamacenes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create alamacene" do
    assert_difference('Alamacene.count') do
      post :create, alamacene: { almacenid: @alamacene.almacenid, tamano: @alamacene.tamano }
    end

    assert_redirected_to alamacene_path(assigns(:alamacene))
  end

  test "should show alamacene" do
    get :show, id: @alamacene
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @alamacene
    assert_response :success
  end

  test "should update alamacene" do
    patch :update, id: @alamacene, alamacene: { almacenid: @alamacene.almacenid, tamano: @alamacene.tamano }
    assert_redirected_to alamacene_path(assigns(:alamacene))
  end

  test "should destroy alamacene" do
    assert_difference('Alamacene.count', -1) do
      delete :destroy, id: @alamacene
    end

    assert_redirected_to alamacenes_path
  end
end
