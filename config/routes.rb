Tvdownweb::Application.routes.draw do
  resources :downloads
  get "/download/*path" => "downloads#create"
  root :to => 'index#index'
end
