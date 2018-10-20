require 'sinatra/reloader'

class CategoryController < ApplicationController
    configure :development do
        register Sinatra::Reloader
    end

    get '/categories' do
        erb :'category/index'
    end

    post '/categories/add' do
      if !exists_already?(params[:category_name])
        binding.pry
        name = params[:category_name]
        cat = Category.create(:category_name => name)
        Category.all << cat
        cat.save
      else
        "Error, category already exists"
      end
        redirect to '/categories'
    end

    helpers do

      def exists_already?(name)
        name = Category.find_by(:category_name => name)
        if name != nil
          return true
        end
        return false
      end
    end
end
