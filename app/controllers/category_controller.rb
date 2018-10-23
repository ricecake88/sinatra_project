require 'rack-flash'

class CategoryController < ApplicationController
  use Rack::Flash
  enable :sessions

    get '/categories' do
      @categories = Category.all
      erb :'category/index'
    end

    patch '/categories/edit' do
      @categories = params[:category]
      @categories.each do |cat|
        category = Category.find(cat["id"])
        if !category.nil?
          if cat["name"] != category.category_name
            category.update(:category_name => cat["name"])
            category.save
            flash[:message] = "Modified category"
          end
        end
      end
      redirect to '/categories'
    end

    post '/categories/add' do
      if !exists_already?(params[:category_name])
        name = params[:category_name]
        cat = Category.create(:category_name => name)
        Category.all << cat
        cat.save
        flash[:message] = "Added category!"
      else
        flash[:message] = "Error, category already exists"
      end
        redirect to '/categories'
    end

    get '/categories/show' do
      @categories = Category.all
      erb :'/category/show'
    end

    delete '/categories/delete' do
      @categories = params[:category]
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
