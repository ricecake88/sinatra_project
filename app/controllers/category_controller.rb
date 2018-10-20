require 'sinatra/reloader'

class CategoryController < ApplicationController
    configure :development do
        register Sinatra::Reloader
    end

    get '/categories' do
      @categories = Category.all
      erb :'category/index'
    end

    post '/categories/edit' do
      @categories = params[:category]
      @categories.each do |cat|
        category = Category.find(cat["id"])
        if !category.nil?
          if cat["name"] != category.category_name
            category.update(:category_name => cat["name"])
            category.save
          end
        end
      end
      redirect to '/categories'
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

    get '/categories/show' do
      @categories = Category.all
      erb :'/category/show'
    end

    delete '/categories/delete' do
      @categories = params[:category]
      binding.pry
      @categories.each do |cat|
        category = Category.find(cat["id"])
        if !category.nil?
          category.delete
        end
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
