require 'rack-flash'

class BudgetController < ApplicationController
  use Rack::Flash
  enable :sessions

  get '/budgets' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      user = Helpers.current_user(session)
      @budgets = user.budgets
      @categories = user.categories
      erb :'budgets/index', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end

  end

  get '/budgets/new' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      user = Helpers.current_user(session)
      Category.create_category_if_empty(session)
      @categories = user.categories_sorted
      erb :'/budgets/new', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/budgets/:id/edit' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      user = Helpers.current_user(session)
      @budget = Budget.find(params[:id])
      @categories = user.categories_sorted
      erb :'/budget/edit', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/budgets/:id' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @budget = Budget.find(params[:id])
      @categories = Helpers.current_user(session).categories
      erb :'/budgets/show', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  post '/budgets/new' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      if cat_exists?(params[:budget]['category'])
        flash[:message] = "OOPS, already set a budget for this category. "
        redirect to "/budgets"
      elsif params[:budget]["amount"].to_d < 0
        flash[:message] = "Error, budget amount must not be negative."
        redirect to "/budgets"
      elsif !params[:budget]["amount"].empty? && !params[:budget]["category"].empty?
        user = Helpers.current_user(session)
        @budget = Budget.new(:category_id => params[:budget]["category"].to_i, :amount => params[:budget]["amount"], :rollover => params[:budget]["rollover"])
        @category = Category.find(params[:budget][:category].to_i)
        if @budget.save
          @category.budget = @budget
          Budget.all << @budget
          redirect to "/budgets/#{@budget.id}"
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
  @sessionName = session
  if Helpers.is_logged_in?(session)
      @budget = Budget.find(params[:id])
      @budget.update(:amount => params[:amount], :rollover => params[:rollover])
      @budget.save
      redirect to '/budgets'
  else
    flash[:message] = "Illegal action. Please log-in to access this page."
    redirect '/'
  end
end

delete '/budgets/:id/delete' do
  @sessionName = session
  if Helpers.is_logged_in?(@sessionName)
    @budget = Budget.find(params[:id])
    if @budget
      @budget.delete
    end
    flash[:message] = "Budget Deleted"
    redirect to '/budgets'
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
