Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboards#show"

  resource :dashboard, only: :show, controller: "dashboards" do
    post :upload
  end

  resources :transactions, only: [:index] do
    member do
      patch :categorize
    end

    collection do
      get :export
      delete :clear_pending
      get :preview
      post :confirm_preview
      delete :discard_preview
    end
  end

  resources :envelopes, except: [:show]
  resources :categories, except: [:show]
end
