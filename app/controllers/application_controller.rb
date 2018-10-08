require_relative '../../config/environment'
require 'sinatra/reloader'

class ApplicationController < Sinatra::Base
    configure :development do
        register Sinatra::Reloader
      end

  get '/' do 
    "Application Controller!"
  end

end