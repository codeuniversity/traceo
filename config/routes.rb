Rails.application.routes.draw do
  resources :traces
  resources :service_versions
  resources :services
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
