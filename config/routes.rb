Rails.application.routes.draw do
  root to: 'rails_admin/main#dashboard'
  get '/health', to: 'main#health'

  scope '(:locale)', locale: /en|pt-BR/ do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  Rails.application.routes.draw do
    post '/graphql', to: 'graphql#execute'
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'non_profits' => 'non_profits#index'
      get 'non_profits/:id/stories' => 'non_profits#stories'
      post 'non_profits' => 'non_profits#create'
      get 'non_profits/:id' => 'non_profits#show'
      put 'non_profits/:id' => 'non_profits#update'
      get 'integrations' => 'integrations#index'
      get 'integrations_mobility_attributes' => 'integrations#mobility_attributes'
      post 'integrations' => 'integrations#create'
      get 'integrations/:id' => 'integrations#show'
      put 'integrations/:id' => 'integrations#update'
      get 'person_payments' => 'person_payments#index'
      post 'donations' => 'donations#create'
      post 'users' => 'users#create'
      post 'users/search' => 'users#search'
      post 'users/can_donate' => 'users#can_donate'
      get 'users/impact' => 'users#impact'
      post 'sources' => 'sources#create'
      post 'rails/active_storage/direct_uploads' => 'direct_uploads#create'
      get 'causes' => "causes#index"
      post 'causes' => "causes#create"
      get 'causes/:id' => "causes#show"
      put 'causes/:id' => "causes#update"

      resources :users, only: [] do
        get 'impacts' => 'users/impacts#index'
        get 'donations_count' => 'users/impacts#donations_count'
        put 'track', to: 'users/trackings#track_user'
      end
      namespace :givings do
        post 'card_fees' => 'fees#card_fees'
        get 'offers' => 'offers#index'
        get 'offers_manager', to: 'offers#index_manager'
        get 'user_givings' => 'user_givings#index'
        post 'impact_by_non_profit' => 'impacts#impact_by_non_profit'
      end
      namespace :payments do
        post 'credit_cards'   => 'credit_cards#create'
        post 'cryptocurrency' => 'cryptocurrency#create'
        put  'cryptocurrency' => 'cryptocurrency#update_treasure_entry_status'
        post 'credit_cards_refund' => 'credit_cards#refund'
      end
      namespace :vouchers do
        post 'donations' => 'donations#create'
      end
      mount_devise_token_auth_for 'UserManager', at: 'auth', skip: [:omniauth_callbacks]
      namespace :manager do
        post 'auth/request', to: 'authorization#google_authorization'
      end
    end
  end

  namespace :integrations, defaults: { format: :json } do
    get 'check' => 'integrations#index'

    namespace :v1 do
      resources :donations, only: %i[index show]
      resources :vouchers, only: [:show]
    end
  end

  namespace :webhooks do
    post 'stripe' => 'stripe#events'
  end
end
