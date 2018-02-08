Mesophotic::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin/db', as: 'rails_admin'

  root "pages#home"

  resources :publications do
    member do
      get :add_validation
      get :behind_edit
      get :behind
      get :detach_field
      get :detach_focusgroup
      get :detach_location
      get :detach_platform
      get :edit_meta
      get :remove_validation
      get :touch_validation
    end
  end

  resources :pages, only: [], path: "" do
    collection do
      get :about
      get :contact
      get :inside
      get :members
      get :posts
      get :stats
      get "members/:id", action: :show_member, as: :member
      get "posts/:id", action: :show_post, as: :post
      post :emailconfirmation, action: :email, as: :email_confirmation
    end
  end

  resources :expeditions
  resources :locations, except: :show
  resources :meetings
  resources :photos
  resources :presentations
  resources :sites
  resources :species

  get ":model/:id", to: "summary#show", as: :summary, constraints: { model: /(platforms|locations|focusgroups|fields)/ }

  devise_for :users, controllers: { registrations: 'registrations' }

  namespace :admin do
    root "base#index"

    resources :users

    resources :publications do
      get :dashboard, on: :collection
      resources :fields, only: [:destroy]
      resources :focusgroups, only: [:destroy]
      resources :platforms, only: [:destroy]
      resources :locations, only: [:destroy]
    end

    resources :posts do
      collection do
        get :drafts
        get :dashboard
      end
    end
  end
end
