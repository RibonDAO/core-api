require 'sidekiq/web'
require "sidekiq/cron/web"

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
  
  mount Sidekiq::Web => '/sidekiq'
  
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'stories' => 'stories#index'
      get 'stories/:id/stories' => 'stories#stories'
      post 'stories' => 'stories#create'
      get 'stories/:id' => 'stories#show'
      put 'stories/:id' => 'stories#update'
      delete 'stories/:id' => 'stories#destroy'
      
      get 'non_profits' => 'non_profits#index'
      get 'free_donation_non_profits' => 'non_profits#free_donation_non_profits'
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
      get 'person_payments/big_donors' => 'person_payments#big_donors'
      get 'person_payments/big_donor_donation/:id' => 'person_payments#big_donor_donation'
      get 'person_payments/:receiver_type' => 'person_payments#payments_for_receiver_by_person'
      post 'donations' => 'donations#create'
      post 'users' => 'users#create'
      post 'users/search' => 'users#search'
      post 'users/can_donate' => 'users#can_donate'
      get 'users/completed_tasks' => 'users#completed_tasks'
      post 'users/complete_task' => 'users#complete_task'
      get 'users/tasks_statistics' => 'users/tasks_statistics#index'
      get 'users/tasks_statistics/streak' => 'users/tasks_statistics#streak'
      post 'users/update_streak' => 'users/tasks_statistics#update_streak'
      post 'users/completed_all_tasks' => 'users/tasks_statistics#first_completed_all_tasks_at'
      get 'users/impact' => 'users#impact'
      get 'users/statistics' => 'users/statistics#index'
      post 'sources' => 'sources#create'
      post 'rails/active_storage/direct_uploads' => 'direct_uploads#create'
      get 'causes' => 'causes#index'
      get 'free_donation_causes' => 'causes#free_donation_causes'
      post 'causes' => 'causes#create'
      get 'causes/:id' => 'causes#show'
      put 'causes/:id' => 'causes#update'
      get 'big_donors' => 'big_donors#index'
      post 'big_donors' => 'big_donors#create'
      get 'big_donors/:id' => 'big_donors#show'
      put 'big_donors/:id' => 'big_donors#update'
      
      namespace :legacy do
        post 'create_legacy_impact' => 'legacy_user_impact#create_legacy_impact'
      end
      
      namespace :news do
        get 'articles' => 'articles#index'
        get 'articles/:id' => 'articles#show'
        post 'articles' => 'articles#create'
        put 'articles/:id' => 'articles#update'

        get 'authors' => 'authors#index'
        get 'authors/:id' => 'authors#show'
        post 'authors' => 'authors#create'
        put 'authors/:id' => 'authors#update'
      end

      resources :users, only: [] do
        get 'impacts' => 'users/impacts#index'
        get 'legacy_impacts' => 'users/legacy_impacts#index'
        get 'legacy_contributions' => 'users/legacy_impacts#contributions'

        get 'donations_count' => 'users/impacts#donations_count'
        put 'track', to: 'users/trackings#track_user'
      end
      resources :integrations, only: [] do
        get 'impacts' => 'integrations/impacts#index'
      end
      namespace :givings do
        post 'card_fees' => 'fees#card_fees'
        get 'offers' => 'offers#index'
        get 'offers/:id' => 'offers#show'

        get 'offers_manager', to: 'offers#index_manager'
        post 'offers' => 'offers#create'
        put 'offers/:id' => 'offers#update'
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
      namespace :configs do
        get 'settings' => 'ribon_config#index'
        put 'settings/:id' => 'ribon_config#update'
      end
      mount_devise_token_auth_for 'UserManager', at: 'auth', skip: [:omniauth_callbacks]
      namespace :manager do
        post 'auth/request', to: 'authorization#google_authorization'
        post 'payments/cryptocurrency/big_donation' => 'payments/cryptocurrency#create_big_donation'
        get 'pools_manager' => 'pools#index'
      end

      namespace :site do 
        get 'non_profits_total_balance' => 'histories#non_profits_total_balance'
        get 'total_donors' => 'histories#total_donors'
        get 'total_donations' => 'site#total_donations'
        get 'non_profits' => 'site#non_profits'
        get 'total_impacted_lives' => 'site#total_impacted_lives'
      end

    end
  end

  namespace :integrations, defaults: { format: :json } do
    get 'check' => 'integrations#index'

    namespace :v1 do
      resources :donations, only: %i[index show]
      resources :vouchers, only: [:show]
      resources :impacts, only: [:index]
    end
  end

  namespace :webhooks do
    post 'stripe' => 'stripe#events'
  end
end
