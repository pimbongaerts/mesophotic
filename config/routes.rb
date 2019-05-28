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

  get :publication_authors, controller: :publications
  get :publication_keywords, controller: :publications

  resources :pages, only: [], path: "" do
    collection do
      get :about
      get :download
      get :contact
      get :inside
      get :members
      get :posts
      get :stats
      get :media_gallery
      get "members/:id", action: :show_member, as: :member
      get "posts/:id", action: :show_post, as: :post
      post :emailconfirmation, action: :email, as: :email_confirmation
    end
  end

  get :member_keywords, controller: :pages
  get :member_research_summary, controller: :pages

  resources :expeditions
  resources :photos
  resources :locations, except: :show
  resources :meetings
  resources :presentations  
  resources :species, except: :show

  resources :sites
  get :site_keywords, controller: :sites
  get :site_research_details, controller: :sites

  get ":model/:id", to: "summary#show", as: :summary, constraints: { model: /(platforms|locations|focusgroups|fields|species)/ }
  get :summary_keywords, controller: :summary
  get :summary_researchers, controller: :summary
  get :summary_publications, controller: :summary

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
