Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'application#index'

  post 'auth/login', to: 'authentication#authenticate'
  post 'signup', to: 'users#create'

  get '/companies' => 'companies#all'
  get '/companies/:id' => 'companies#one'

end
