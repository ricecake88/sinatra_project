require_relative '../../config/environment'
require 'sinatra/reloader'

class ApplicationController < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :session_secret, "my_application_secret"
  set :views, Proc.new { File.join(root, "../views/") }

    configure :development do
        register Sinatra::Reloader
      end

  get '/' do 
    erb :'index'
  end

end