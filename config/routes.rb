# frozen_string_literal: true

Rails.application.routes.draw do
  # Mount Sidekiq Web UI for monitoring background jobs (admin only)
  require "sidekiq/web"
  require "sidekiq/cron/web"

  # Protect Sidekiq Web UI with admin authentication
  class AdminConstraint
    def matches?(request)
      return false unless (session_token = request.cookie_jar.signed[:session_token])
      session = Session.find_by(id: session_token)
      session&.user&.admin?
    end
  end

  mount Sidekiq::Web, at: "/jobs", constraints: AdminConstraint.new

  get  "sign_in", to: "sessions#new", as: :sign_in
  post "sign_in", to: "sessions#create"
  get  "sign_up", to: "users#new", as: :sign_up
  post "sign_up", to: "users#create"

  resources :sessions, only: [:destroy]
  resource :users, only: [:destroy]

  namespace :identity do
    resource :email_verification, only: [:show, :create]
    resource :password_reset,     only: [:new, :edit, :create, :update]
  end

  get :dashboard, to: "dashboard#index"

  namespace :settings do
    resource :profile, only: [:show, :update]
    resource :password, only: [:show, :update]
    resource :email, only: [:show, :update]
    resources :sessions, only: [:index]
    inertia :appearance
  end

  namespace :admin do
    get :dashboard, to: "dashboard#index"

    resources :scryfall_syncs, only: [:index, :show], defaults: {format: :json} do
      collection do
        get :progress
        post :start
      end
      member do
        post :cancel
        post :retry
      end
    end

    resources :open_search_syncs, only: [:index, :show, :create, :destroy], defaults: {format: :json} do
      collection do
        get :progress
      end
    end

    resources :search_evals, only: [:index, :show, :create, :destroy], defaults: {format: :json} do
      collection do
        get :progress
      end
    end

    resources :embedding_runs, only: [:index, :show, :create, :destroy], defaults: {format: :json} do
      collection do
        get :progress
      end
    end

    resources :failures, only: [:index] do
      collection do
        post :clear
      end
    end

    root to: "dashboard#index"
  end

  namespace :api do
    resources :cards, only: [] do
      collection do
        get :autocomplete
        get :search
        get :keywords
        get :types
      end
    end
  end

  root "home#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
