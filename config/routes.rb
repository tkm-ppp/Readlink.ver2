Rails.application.routes.draw do

  root to: "homes#top"

  get 'books/search', to: 'books#search', as: 'books_search'
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


