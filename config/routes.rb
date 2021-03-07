Rails.application.routes.draw do
  resources :questions
  resources :rounds, only: [ :edit, :update ]
  resources :games do
    member do
      patch 'next_round'
    end
  end
  resources :admins, only: :index
  resources :teams, only: [:show, :update, :edit]
  resources :team_answers, only: [:create, :update]
end
