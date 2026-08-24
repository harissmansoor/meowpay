Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'cats#index'
  resources :cats, only: [:index, :show]
  resources :transfers, only: [:create]
end
