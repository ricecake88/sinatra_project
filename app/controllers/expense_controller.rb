require 'rack-flash'

class ExpenseController < ApplicationController
  use Rack::Flash
  enable :sessions

  get '/expense' do
    @expenses = Expense.all
    erb :'expense/index'
  end

  get '/expense/add' do
    erb :'expense/add'
  end

  get '/expense/:id' do
    @expense = Expense.find(params[:id])
    erb :'expense/show'
  end

  post '/expense/add' do
    if (!params[:expense]["date"].empty? &&
        !params[:expense]["amount"].empty? &&
        !params[:expense]["description"].empty? &&
        !params[:expense]["merchant"].empty?)
        @matched_expense = entry_already_exists?(params[:expense])
        if !@matched_expense
          @expense = Expense.create(params[:expense])
          Expense.all << @expense
          @expense.save
          flash[:message] = "Expense added"
          redirect to "/expense/#{@expense.id}"
        else
          flash[:message] = "Already added"
          redirect '/expense/add'
        end
    else
      flash[:message] = "Missing Fields"
      redirect '/expense/add'
    end
  end

  helpers do
    def entry_already_exists?(expense)
      @matched_expense_by_date = Expense.find_by(:date => expense['date'])
      if (@matched_expense_by_date["merchant"] == expense["merchant"] &&
          @matched_expense_by_date["amount"].to_f == expense["amount"].to_f)
          return true
      else
        return false
      end
    end
  end
end
