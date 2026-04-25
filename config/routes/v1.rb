# frozen_string_literal: true

namespace :v1 do
  draw(:devise)

  namespace :admin do
    resources :users, only: %i[index show create update destroy] do
      member do
        patch :deactivate
        patch :reactivate
      end
    end
  end
end
