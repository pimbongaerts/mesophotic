Mesophotic::Application.routes.draw do
  mount RailsAdmin::Engine => "/admin/db", as: "rails_admin"

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
    collection do
      post :touch_validations
    end
  end

  get :publication_authors, controller: :publications
  get :publication_keywords, controller: :publications

  resources :pages, only: [], path: "" do
    collection do
      get :about
      get :tutorial
      get :metadata, to: redirect('/about')
      get :contact
      get :inside
      get :members
      get :posts
      get :media_gallery
      get "members/:id", action: :show_member, as: :member
      get "posts/:id", action: :show_post, as: :post
      post :emailconfirmation, action: :email, as: :email_confirmation
    end
  end

  get :member_keywords, controller: :pages
  get :member_research_summary, controller: :pages

  resources :stats, only: [], path: 'statistics' do
    collection do
      get :index, to: redirect('statistics/all/2023')
      get "all/:year", to: "stats#all", as: :all
      get "validated/:year", to: "stats#validated", as: :validated
    end
  end
  get :growing_depth_range, controller: :stats
  get :growing_publications_over_time, controller: :stats
  get :growing_locations_over_time, controller: :stats
  get :growing_authors_over_time, controller: :stats
  get :summarized_fields, controller: :stats
  get :summarized_journals, controller: :stats
  get :summarized_focusgroups, controller: :stats
  get :summarized_platforms, controller: :stats
  get :world_publications, controller: :stats
  get :world_users, controller: :stats
  get :world_locations, controller: :stats
  get :time_refuge, controller: :stats
  get :time_mesophotic, controller: :stats

  resources :expeditions
  resources :photos
  resources :locations, except: :show
  resources :meetings
  resources :presentations
  resources :species, except: :show
  get :species_image, controller: :species

  get :world_map, controller: :maps

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
