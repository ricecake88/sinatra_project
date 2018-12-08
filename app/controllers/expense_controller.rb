require 'rack-flash'

class ExpenseController < ApplicationController
  use Rack::Flash
  enable :sessions

  get '/expense' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      user = Helpers.current_user(@sessionName)
      @expenses = Helpers.expenses_for_user(user)
      binding.pry
      erb :'expense/index'
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/expense/add' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      erb :'expense/add'
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/expense/select' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @expenses = Helpers.expenses_for_user(Helpers.current_user(session))
      erb :'expense/select'
    else
      flash[:message] = "Illegal action. Please log-in to access this page/"
      redirect '/'
    end
  end

  post '/expense/:id/edit' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      binding.pry
      @expense = Expense.find(params[:expense_id])
      erb :'expense/edit'
    else
      flash[:message] = "Illegal action. Please log-in to access this page/"
      redirect '/'
    end
  end

  get '/expense/:id' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @expense = Expense.find(params[:id])
      erb :'expense/show'
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  post '/expense/add' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
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
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  helpers do
    def entry_already_exists?(expense)
      binding.pry
      @matched_expense_by_date = Expense.find_by(:date => expense['date'])
      if @matched_expense_by_date.nil?
        return false
      elsif (@matched_expense_by_date["merchant"] == expense["merchant"] &&
          @matched_expense_by_date["amount"].to_f == expense["amount"].to_f)
        return true
      else
        return false
      end
    end
  end
end
