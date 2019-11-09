Rails.application.routes.draw do

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

  get 'services', to: 'services#get_services'
  post 'services', to: 'services#create_service'
  put 'services/:service_id', to: 'services#update_service'
  post 'services/add/:service_id', to: 'services#add_service'
  post 'services/remove/:service_id', to: 'services#remove_service'

end
