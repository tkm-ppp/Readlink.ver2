Rails.application.routes.draw do

  root to: "homes#top"

  get 'books/search', to: 'books#search', as: 'search_books'

  resources :libraries, only: [:index]


# devise_for :users, controllers: {
#   sessions: "users/sessions",
#   registrations: "users/registrations"
# }

# devise_scope :user do
#   get "/users/sign_out" => "devise/sessions#destroy"
# end

# resources :users, only: [ :show ]


end