Rails.application.routes.draw do
  resources :sku_stocks
  resources :precios
  resources :costos
  resources :tiempos
  resources :produccions
  resources :oc_recibidas
  resources :oc_rcibidas
  resources :tasks

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  root 'home#index'
  get 'dashboard' => 'dashboard#index'
  get 'charts' => 'charts#index'
  get 'testing' => 'testing#index'
  get 'orders' => 'orders#index'
  get 'cellar' => 'cellar#index'
  get 'api' => 'api#index'
  get 'documentation' => 'documentation#index'
  get 'api/consultar/:sku' => 'api#got_stock'
  put 'oc/crear'=> 'oc_recibidas#crear_oc_api'
  get 'api/pagos/recibir/:idtrx' => 'api#recibir_trx'
  get 'api/oc/recibir/:idoc' => 'api#gestionar_oc'
  get 'api/facturas/recibir/:idfactura' => 'api#recibir_factura', defaults: {format: :json}
  get 'api/javi_prueba' => 'api#time'

  get 'api/test_felipe' => 'produccions#ApiProducirMp'
  get 'api/test_felipe2' => 'orders#comprar_producto'
  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
