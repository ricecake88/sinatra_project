class BudgetController < ApplicationController

  get '/budgets' do
    user = current_user
    if is_logged_in? && !user.nil?
      @budgets = user.budgets
      @categories = user.categories
      erb :'budgets/index', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end

  end

  get '/budgets/new' do
    user = current_user
    if is_logged_in? && !user.nil?
      Category.create_category_if_empty(session)
      @categories = user.categories_sorted
      erb :'/budgets/new', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/budgets/:id/edit' do
    user = current_user
    if is_logged_in? && !user.nil?
      @budget = Budget.find(params[:id])
      @categories = user.categories_sorted
      erb :'/budgets/edit', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/budgets/:id' do
    user = current_user
    if is_logged_in? && !user.nil?
      @budget = Budget.find(params[:id])
      @categories = Helpers.current_user(session).categories
      erb :'/budgets/show', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  post '/budgets/create' do
    user = current_user
    if is_logged_in? && !user.nil?
      if cat_exists?(params[:budget]['category'])
        flash[:message] = "OOPS, already set a budget for this category. "
        redirect to "/budgets"
      elsif params[:budget]["amount"].to_d < 0
        flash[:message] = "Error, budget amount must not be negative."
        redirect to "/budgets"
      elsif !params[:budget]["amount"].empty? && !params[:budget]["category"].empty?
        @budget = Budget.new(:category_id => params[:budget]["category"].to_i, :amount => params[:budget]["amount"], :rollover => params[:budget]["rollover"])
        @category = Category.find(params[:budget][:category].to_i)
        if user == Category.find(@budget.category_id).user && @budget.save
          @category.budget = @budget
          Budget.all << @budget
          redirect to "/budgets/#{@budget.id}"
        else
          flash[:message] = "You do not have permission to do that."
          redirect to '/'
        end
      else
        flash[:message] = "Sorry, either the amount or category entered is empty"
        redirect to "/budgets/add"
      end
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      erb :'/'
    end
  end

patch '/budgets/:id/edit' do
  user = current_user
  if is_logged_in? && !user.nil?
      @budget = Budget.find(params[:id])
      @budget.update(:amount => params[:amount], :rollover => params[:rollover])
      if user == Category.find(@budget.category_id).user && @budget.save
        redirect to '/budgets'
      else
        flash[:message] = "You do not have permission to do that."
        redirect to '/'
      end
  else
    flash[:message] = "Illegal action. Please log-in to access this page."
    redirect '/'
  end
end

delete '/budgets/:id/delete' do
  user = current_user
  if is_logged_in? && !user.nil?
    @budget = Budget.find(params[:id])
    if @budget && user == Category.find(@budget.category_id).user
      @budget.delete
      flash[:message] = "Budget Deleted"
      redirect to '/budgets'
    else
      flash[:message] = "You do not have permission to do that."
      redirect to '/'
    end
  else
    flash[:message] = "Illegal action. Please log-in to access this page."
    redirect to '/'
  end
end

  helpers do
    def cat_exists?(cat_id)
      Budget.find_by(:category_id => cat_id.to_i)
    end
  end

end
