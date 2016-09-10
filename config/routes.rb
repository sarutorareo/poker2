Rails.application.routes.draw do
  root to: 'rooms#index'

  resources :rooms , only: [:index, :show] do
    get 'start_hand', :on => :member
  end

#  mount ActionCable.server => '/cable'
end
