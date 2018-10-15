require 'sinatra/reloader'

class CategoryController < ApplicationController
    configure :development do
        register Sinatra::Reloader
    end

    get '/categories' do
        erb :'category/index'
    end
end