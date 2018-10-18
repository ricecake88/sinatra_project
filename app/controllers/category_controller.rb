require 'sinatra/reloader'

class CategoryController < ApplicationController
    configure :development do
        register Sinatra::Reloader
    end

    get '/categories' do
        erb :'category/index'
    end

    post '/categories' do
        name = params[:category_name]
        cat = Category.create(:category_name => name)
        Category.all << cat
        cat.save

        redirect to '/categories'
    end

    helpers do 
    end
end