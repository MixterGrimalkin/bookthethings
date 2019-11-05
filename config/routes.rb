Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'application#index'

  post 'auth/login', to: 'authentication#authenticate'
  post 'signup', to: 'users#create'

  get 'customers/details', to: 'customers#details'
  get 'customers/locations', to: 'customers#locations'
  get 'customers/companies', to: 'customers#companies'

  post 'customers/request', to: 'customers#request_customership'
  post 'customers/enable', to: 'customers#enable_customership'

end
