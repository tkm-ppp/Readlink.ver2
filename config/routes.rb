Rails.application.routes.draw do

  root to: "homes#top"

  devise_for :users, controllers: {
  sessions: 'users/sessions',
  registrations: 'users/registrations',
  }
  get "users" => redirect("/users/sign_up")

  get 'books/search', to: 'books#search', as: 'search_books'
  get 'books/:isbn', to: 'books#show', as: 'book'

  get 'regions', to: 'regions#index', as: 'regions'
  get 'regions/:pref_name', to: 'regions#show', as: 'region'


  get 'libraries/:systemid/:libkey', to: 'libraries#show', as: 'library'


# devise_for :users, controllers: {
#   sessions: "users/sessions",
#   registrations: "users/registrations"
# }

# devise_scope :user do
#   get "/users/sign_out" => "devise/sessions#destroy"
# end

# resources :users, only: [ :show ]


end


