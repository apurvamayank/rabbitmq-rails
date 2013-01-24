RailsUsingRabbit::Application.routes.draw do
  root :to => "home#index"

  get "home/index"
  post "home/publish"
  post "home/get_message"

end
