Rails.application.routes.draw do
  root to: 'rooms#index'

  resources :rooms, only: [:index, :show]

#  mount ActionCable.server => '/cable'
end
