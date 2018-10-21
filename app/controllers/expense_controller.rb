class ExpenseController < ApplicationController

    get '/expense' do
      @expenses = Expense.all
      erb :'expense/index'
    end

    get '/expense/add' do
      erb :'expense/add'
    end

    post '/expense/add' do
      binding.pry
    end
end
