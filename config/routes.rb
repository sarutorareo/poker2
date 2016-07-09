Rails.application.routes.draw do
  get 'rooms/show'

  root to: 'rooms#show'
  get 'room/show'

  get 'top/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "top#index"

#  mount ActionCable.server => '/cable'
end
