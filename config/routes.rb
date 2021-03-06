Rails.application.routes.draw do
  resources :events
  get 'events/:id/join', to: 'events#join', as: "join_event"
  root 'events#index'
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/callback', to: 'users#callback', as: 'callback'
  resources :users, only: [:edit, :update]
end
