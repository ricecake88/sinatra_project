require 'rack-flash'

class CategoryController < ApplicationController
  use Rack::Flash
  enable :sessions

  get '/categories' do
    @sessionName = session
    @categories = []
    user = Helpers.current_user(session)
    if Helpers.is_logged_in?(session) && !user.nil?
      Category.create_category_if_empty(@sessionName)
      @categories = user.categories_sorted
      erb :'categories/index', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  patch '/categories/edit' do
    @sessionName = session
    user = Helpers.current_user(session)
    if Helpers.is_logged_in?(session) && !user.nil?
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

  post '/categories/new' do
    @sessionName = session
    user = Helpers.current_user(session)
    if Helpers.is_logged_in?(session) && !user.nil?
      if !params[:category_name].empty?
        if !exists_already?(params[:category_name])
          name = params[:category_name]
          category = Category.new(:category_name => params[:category_name])
          category.user = user
          if category.save
            user.categories << category
            Category.all << category
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

  get '/categories/delete' do
    @sessionName = session
    user = Helpers.current_user(session)
    if Helpers.is_logged_in?(session) && !user.nil?
      @categories = Category.sort_categories(session)
      erb :'/categories/delete', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  delete '/categories/delete' do
    @sessionName = session
    user = Helpers.current_user(session)
    if Helpers.is_logged_in?(session) && !user.nil?
      @categories = params[:category]
      if !@categories.nil?
        @categories.each do |cat|
          expenses_current_category = Expense.where(:category_id => cat["id"])
          if !expenses_current_category.empty?
            set_category_to_default(expenses_current_category)
          end
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
      if !name.nil?
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
