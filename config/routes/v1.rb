# frozen_string_literal: true

namespace :v1 do
  draw(:devise)

  resources :households, only: %i[index show create update] do
    collection do
      patch :bulk_update_status
    end
    member do
      patch :archive
      patch :update_status
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
