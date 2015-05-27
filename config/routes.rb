Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get '/logout' => 'devise/sessions#destroy'
  end
 
  root to: 'homepage#index'
end
