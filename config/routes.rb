Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'game', to: 'wordgame#game'

  get 'score', to: 'wordgame#score'
end
