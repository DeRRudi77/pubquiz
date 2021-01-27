Rails.application.routes.draw do
  resources :rounds, only: [ :edit, :update ]
  resources :games
  resources :admins, only: :index
  resources :teams, only: [:show, :update, :edit]
  resources :answers, only: [:create, :update]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
