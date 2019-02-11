
class CategoryController < ApplicationController

  get '/categories' do
    #@categories = []
    redirect_if_not_logged_in
    Category.create_category_if_empty(current_user)
   #@categories = current_user.categories_sorted
    erb :'categories/index', :layout => :layout_loggedin
  end

  patch '/categories/edit' do
    redirect_if_not_logged_in
    if !params[:category].nil?
      @categories = params[:category]
      @categories.each do |cat|
        redirect_if_expense_category(cat["id"])
        category = Category.find_by(:id => cat["id"])
        redirect_if_not_valid_user_or_record(category)
        if cat["name"] != category.category_name
          category.update(:category_name => cat["name"])
          category.save
          flash[:message] = "Modified category"
        end
      end
    else
      flash[:message] = "No category modified, missing category data."
    end
    redirect to '/categories'
  end

  post '/categories/new' do
    redirect_if_not_logged_in
    redirect_if_category_is_invalid(params[:category_name])
    #if !params[:category_name].empty?
      #if !exists_already?(params[:category_name])
        #name = params[:category_name]
        category = Category.new(:category_name => params[:category_name])
        category.user = current_user
        if category.save
          #current_user.categories << category
          #Category.all << category
          flash[:message] = "Added category!"
          redirect to '/categories'
        end
      #else
      #  flash[:message] = "Error, category already exists"
      #end
    #else
    #  flash[:message] = "Error, category is empty."
    #end
    #redirect to '/categories'
  end

  get '/categories/delete' do
    redirect_if_not_logged_in
    #@categories = current_user.categories_sorted
    erb :'/categories/delete', :layout => :layout_loggedin
  end

  delete '/categories/delete' do
    redirect_if_not_logged_in
    @categories = params[:category]
    if @categories
      @categories.each do |cat|
        redirect_if_expense_category(cat["id"])
        expenses_in_current_category = Expense.where(:category_id => cat["id"])
        if !expenses_in_current_category.empty?
          set_category_to_default(expenses_in_current_category)
        end
        category = Category.find_by(:id => cat["id"])
        redirect_if_not_valid_user_or_record(category)
        category.delete
      end
      flash[:message] = "Category or Categories Deleted."
    else
      flash[:message] = "No categories selected."
    end
    redirect to '/categories'
  end

  helpers do

    def exists_already?(name)
      !Category.find_by(:category_name => name, :user_id => session[:user_id]).nil?
    end

    def set_category_to_default(expenses)
      @categories = current_user.categories
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
      end
    end

    def redirect_if_expense_category(id)
      if Category.find_by(:id => id, :category_name => "Expenses")
        flash[:message] = "You do not have permission to do that."
        redirect '/'
      end
    end

    def redirect_if_category_is_invalid(name)
      valid = false
      if name.empty?
        flash[:message] = "Error, category is empty."
      elsif exists_already?(name)
        flash[:message] = "Error, category already exists"
      else
        valid = true
      end
      if !valid
        redirect to '/categories'
      end
    end

  end #end helpers

end
