Rails.application.routes.draw do
  resources :traces, except: [:update, :destroy]
  resources :service_versions, except: [:update, :destroy]
  resources :services, except: [:update, :destroy]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
