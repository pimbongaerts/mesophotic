Mesophotic::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin/db', as: 'rails_admin'

  root "pages#home"

  resources :photos
  resources :meetings
  resources :expeditions
  resources :presentations
  resources :species
  resources :sites
  resources :locations, { except: :show }

  resources :publications do
    member do
      get 'edit_meta'
      get 'detach_field'
      get 'detach_focusgroup'
      get 'detach_platform'
      get 'detach_location'
      get 'add_validation'
      get 'remove_validation'
      get 'touch_validation'
      get 'behind'
      get 'behind_edit'
    end
  end

  get "home", to: "pages#home", as: "home"
  get "inside", to: "pages#inside", as: "inside"
  get "/contact", to: "pages#contact", as: "contact"
  get "/about", to: "pages#about", as: "about"
  get "/stats", to: "pages#stats", as: "stats"
  post "/emailconfirmation", to: "pages#email", as: "email_confirmation"

  get "posts", to: "pages#posts", as: "posts"
  get "posts/:id", to: "pages#show_post", as: "post"
  devise_for :users, controllers: { registrations: 'registrations' }
  get "members", to: "pages#members", as: "members"
  get "members/:id", to: "pages#show_member", as: "member"

  namespace :admin do
    root "base#index"
    get "publications/dashboard", to: "publications#dashboard",
                        as: "publications_dashboard"
    resources :publications do
      resources :fields, only: [:destroy]
      resources :focusgroups, only: [:destroy]
      resources :platforms, only: [:destroy]
      resources :locations, only: [:destroy]
    end
    resources :users
    resources :posts
    get "posts/drafts", to: "posts#drafts", as: "posts_drafts"
    get "posts/dashboard", to: "posts#dashboard", as: "posts_dashboard"
  end

  get ":model/:id", to: "summary#show", as: "summary", constraints: { model: /(platforms|locations|focusgroups|fields)/ }
end
