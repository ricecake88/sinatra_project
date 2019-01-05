require 'rack-flash'

class CategoryController < ApplicationController
  use Rack::Flash
  enable :sessions

  get '/categories' do
    @sessionName = session
    @categories = []
    if Helpers.is_logged_in?(session)
      Category.create_category_if_empty(@sessionName)
      @categories = Category.sort_categories(@sessionName)
      erb :'category/index', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  patch '/categories/edit' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      if !params[:category].nil?
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
      else
        flash[:message] = "No category modified, missing category data."
      end
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
    redirect to '/categories'
  end

  post '/categories/add' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      if !params[:category_name].empty?
        if !exists_already?(params[:name])
          name = params[:category_name]
          user = Helpers.current_user(session)
          user_category = Category.new(:category_name => params[:category_name])
          user_category.user = user
          if user_category.save
            user.categories << user_category
            Category.all << user_category
            flash[:message] = "Added category!"
          end
        else
          flash[:message] = "Error, category already exists"
        end
      else
        flash[:message] = "Error, category is empty."
      end
      redirect to '/categories'
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect to '/'
    end
  end

  get '/categories/show' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @categories = Category.sort_categories(session)
      erb :'/category/show', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  delete '/categories/delete' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @categories = params[:category]
      if !@categories.nil?
        @categories.each do |cat|
          expenses_current_category = Expense.expenses_by_user_category(session, cat["id"])
          set_category_to_default(expenses_current_category)
          category = Category.find(cat["id"])
          if !category.nil?
            category.delete
          end
        end
      else
        flash[:message] = "No categories selected."
      end
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
    redirect to '/categories'
  end

  helpers do

    def exists_already?(name)
      name = Category.find_by(:category_name => name, :user_id => session[:user_id])
      if name != nil
        return true
      end
      return false
    end

    def set_category_to_default(expenses)
      @categories = Helpers.current_user(session).categories
      default_user_category_id = 0
      @categories.each do |cat|
        if cat.category_name == "Expenses"
          default_user_category_id = cat.id
          break
        end
      end
      expenses.each do |expense|
        expense_row = Expense.find(expense.id)
        expense_row.update(:category_id => default_user_category_id)
        expense_row.save
      end
    end
  end
end
