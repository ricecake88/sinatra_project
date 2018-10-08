require_relative '../../config/environment'
require 'sinatra/reloader'

class ApplicationController < Sinatra::Base
    configure :development do
        register Sinatra::Reloader
      end

  get '/' do 
    "Application Controller At least this still works Test?!"
  end

end