# frozen_string_literal: true

namespace :v1 do
  draw(:devise)

  resources :households, only: %i[index show create update] do
    collection do
      patch :bulk_update_status
      post :import
      get :csv_template
      get :export
      get :map
      get :status_updates
    end
    member do
      patch :archive
      patch :update_status
      patch :assign_center
    end
  end

  resources :residents, only: %i[index show create update] do
    collection do
      get :export
    end
    member do
      patch :archive
    end
  end

  resources :risk_zones, only: %i[index show create update destroy]

  scope :typhoon_mode, controller: :typhoon_mode do
    get "/", action: :status, as: :typhoon_mode_status
    post :activate, action: :activate
    post :deactivate, action: :deactivate
  end

  get "dashboard/summary", to: "dashboard#summary"
  get "activity_feed", to: "activity_feed#index"
  get "analytics", to: "analytics#index"

  resources :evacuation_events, only: %i[index show create] do
    collection do
      get :history
      get :export_report
    end
    member do
      patch :resolve
    end
  end

  resources :evacuation_centers, only: %i[index show create update] do
    member do
      patch :update_occupancy
    end
  end

  namespace :admin do
    resources :users, only: %i[index show create update destroy] do
      member do
        patch :deactivate
        patch :reactivate
      end
    end
  end
end
