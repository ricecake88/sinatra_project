
class CategoryController < ApplicationController

  get '/categories' do
    redirect_if_not_logged_in
    Category.create_category_if_empty(current_user)
    erb :'categories/index', :layout => :layout_loggedin
  end

  patch '/categories/edit' do
    redirect_if_not_logged_in
    redirect_if_no_categories(params[:category])
    params[:category].each do |cat|
      category = Category.find_by(:id => cat["id"])
      redirect_if_not_valid_user_or_record(category)
      redirect_if_category_is_invalid(category.category_name, "patch")
      if cat["name"] != category.category_name
        category.update(:category_name => cat["name"])
        flash[:message] = "Modified category"
      end
    end
    redirect to '/categories'
  end

  post '/categories/new' do
    redirect_if_not_logged_in
    redirect_if_category_is_invalid(params[:category_name], "post")
    category = Category.new(:category_name => params[:category_name])
    category.user = current_user
    if category.save
      flash[:message] = "Added category!"
      redirect to '/categories'
    end
  end

  get '/categories/delete' do
    redirect_if_not_logged_in
    erb :'/categories/delete', :layout => :layout_loggedin
  end

  delete '/categories/delete' do
    redirect_if_not_logged_in
    redirect_if_no_categories(params[:category])
    params[:category].each do |cat|
      category = Category.find_by(:id => cat["id"])
      redirect_if_not_valid_user_or_record(category)
      redirect_if_category_is_invalid(category.category_name, "delete")
      set_category_to_default(category)
      category.delete
      flash[:message] = "Category or Categories Deleted."
    end
    redirect to '/categories'
  end

  helpers do

    def exists_already?(name)
      !Category.find_by(:category_name => name, :user_id => session[:user_id]).nil?
    end

    def set_category_to_default(category)
      if !category.expenses.empty?
        default_user_category_id = 0

        current_user.categories.each do |cat|
          if cat.category_name == "Expenses"
            default_user_category_id = cat.id
            break
          end
        end

        category.expenses.each do |ex|
          ex.category_id = default_user_category_id
          ex.update(:category_id => default_user_category_id)
        end
      end
    end

    def redirect_if_category_is_invalid(name, action)
      valid = false
      path = '/categories'
      if name == "Expenses"
        flash[:message] = "You do not have permission to do that."
        path = '/'
      elsif name.empty?
        flash[:message] = "Error, category is empty."
      elsif exists_already?(name) && action == "post"
        flash[:message] = "Error, category already exists"
      else
        valid = true
      end
      if !valid
        redirect to '/categories'
      end
    end

    def redirect_if_no_categories(category_ids)
      if !category_ids
        flash[:message] = "No categories selected"
        redirect to '/categories'
      end
    end

  end #end helpers

end
