# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run FinforeWeb::Application
#use Rack::Cors do
#  allow do
#    origins '*'
#    resource '/public/*', :headers => :any, :methods => [:get,:post,:put,:delete,:options]
#    resources :users
#  end
#end
#use XOriginEnabler
