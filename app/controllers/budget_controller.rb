require 'rack-flash'

class BudgetController < ApplicationController
  use Rack::Flash
  enable :sessions

  get '/budgets' do
    binding.pry
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @budgets = Budget.all
      erb :'budget/index'
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      erb :'/'
    end

  end

  get '/budgets/add' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      erb :'/budget/add'
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      erb :'/'
    end
  end

  get '/budgets/:id/edit' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @budget = Budget.find(params[:id])
      erb :'/budget/edit'
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      erb :'/'
    end
  end

  get '/budgets/:id' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @budget = Budget.find(params[:id])
      erb :'/budget/show'
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      erb :'/'
    end
  end

  post '/budgets/add' do
    binding.pry
    @sessionName = session
    if Helpers.is_logged_in?(session)
      if cat_exists?(params[:budget]['category'])
        flash[:message] = "OOPS, already set a budget for this category"
        redirect to "/budgets/add"
      elsif !params[:budget]["amount"].empty? && !params[:budget]["category"].empty?
        binding.pry
        @budget = Budget.create(:category_id => params[:budget]["category"].to_i, :amount => params[:budget]["amount"])
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
    binding.pry
    @budget = Budget.find(params[:id])
    @budget.update(:amount => params[:amount])
    @budget.save
    redirect to '/budgets'
  else
    flash[:message] = "Illegal action. Please log-in to access this page."
    erb :'/'
  end
end


  helpers do
    def cat_exists?(cat_id)
      Budget.find_by(:category_id => cat_id.to_i)
    end
  end

end
