Rails.application.routes.draw do
  devise_for :users

  resources :fixtures
  resources :picks
  resources :results do
    collection { get :leaderboard }
    member { post :cancel }
  end
  resources :team_wrappers
  resources :leagues do
    member {
      get :view
      post :join
      get :join
      post :action
    }
  end

  resource :user do
    post :fixtures
  end

  root to: "home#index"
end
