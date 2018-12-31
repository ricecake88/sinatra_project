require 'rack-flash'

class CategoryController < ApplicationController
  use Rack::Flash
  enable :sessions

  get '/categories' do
    @sessionName = session
    @categories = []
    if Helpers.is_logged_in?(session)
      user_id = Helpers.current_user(session).id
      Category.create_category_if_empty(@sessionName)
      Category.all.each do |cat|
        if cat.user_id == user_id
          @categories << cat
        end
        @categories.sort_by!{ |c| c.category_name.downcase }
      end
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
      if !exists_already?(params[:category_name])
        name = params[:category_name]
        user = Helpers.current_user(@sessionName)
        cat = Category.create(:category_name => name, :user_id => user.id)
        Category.all << cat
        cat.save
        flash[:message] = "Added category!"
      else
        flash[:message] = "Error, category already exists"
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
      @categories = Category.categories_of_user(@sessionName)
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
      name = Category.find_by(:category_name => name)
      if name != nil
        return true
      end
      return false
    end

    def set_category_to_default(expenses)
      @categories = Category.categories_of_user(session)
      default_user_category_id = 0
      @categories.each do |cat|
        if cat.category_name == "Expenses"
          default_user_category_id = cat.id
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
