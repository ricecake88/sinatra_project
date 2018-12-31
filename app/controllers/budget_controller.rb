require 'rack-flash'

class BudgetController < ApplicationController
  use Rack::Flash
  enable :sessions

  get '/budgets' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @budgets = Budget.budgets_for_user(@sessionName)
      erb :'budget/index', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      erb :'/'
    end

  end

  get '/budgets/add' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      Category.create_category_if_empty(@sessionName)
      erb :'/budget/add', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      erb :'/'
    end
  end

  get '/budgets/:id/edit' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @budget = Budget.find(params[:id])
      erb :'/budget/edit', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      erb :'/'
    end
  end

  get '/budgets/:id' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @budget = Budget.find(params[:id])
      erb :'/budget/show', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      erb :'/'
    end
  end

  post '/budgets/add' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      if cat_exists?(params[:budget]['category'])
        flash[:message] = "OOPS, already set a budget for this category. "
        redirect to "/budgets"
      elsif params[:budget]["amount"].to_d < 0
        flash[:message] = "Error, budget amount must not be negative."
        redirect to "/budgets"
      elsif !params[:budget]["amount"].empty? && !params[:budget]["category"].empty?
        @budget = Budget.create(:category_id => params[:budget]["category"].to_i, :amount => params[:budget]["amount"], :rollover => params[:budget]["rollover"])
        Budget.all << @budget
        @budget.save
        redirect to "/budgets/#{@budget.id}"
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
    erb :'/'
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
