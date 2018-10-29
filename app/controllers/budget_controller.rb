require 'rack-flash'

class BudgetController < ApplicationController
  use Rack::Flash
  enable :sessions

  get '/budgets' do
    @budgets = Budget.all
    erb :'budget/index'
  end

  get '/budgets/add' do
    erb :'/budget/add'
  end

  get '/budgets/:id' do
    @budget = Budget.find(params[:id])
    binding.pry
    erb :'/budget/show'
  end

  post '/budgets/add' do
    if cat_exists?(params[:budget]["category"])
      flash[:message] = "OOPS, already set a budget for this category"
      redirect to "/budgets/add"
    elsif !params["budget"]["amount"].empty? && !params["budget"]["category"].empty?
      @budget = Budget.create(:category_id => params["budget"]["category"].to_i, :amount => params["budget"]["amount"])
      Budget.all << @budget
      @budget.save
      redirect to "/budgets/#{@budget.id}"
    else
      "No"
    end
  end

  helpers do
    def cat_exists?(cat_id)
      Budget.find_by(:category_id => cat_id.to_i)
    end
  end

end
