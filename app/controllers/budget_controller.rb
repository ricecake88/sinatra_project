class BudgetController < ApplicationController
  get '/budgets' do
    @budgets = Budget.all
    erb :'budget/index'
  end
end
