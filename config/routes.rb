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

  get 'locations', to: 'locations#get_locations'
  post 'locations/create', to: 'locations#create_location'
  post 'locations/update/:id', to: 'locations#update_location'
  post 'locations/link-customer/:id', to: 'locations#link_customer'
  post 'locations/link-provider/:id', to: 'locations#link_provider'

end
