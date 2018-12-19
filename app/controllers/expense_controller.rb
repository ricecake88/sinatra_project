require 'rack-flash'

class ExpenseController < ApplicationController
  use Rack::Flash
  enable :sessions

  get '/expense' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @expenses = Expense.expenses_for_user(@sessionName)
      erb :'expense/index', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/expense/add' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      erb :'expense/add', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/expense/select' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      @expenses = Expense.expenses_for_user(@sessionName)
      erb :'expense/select', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page/"
      redirect '/'
    end
  end

  patch '/expense/:id' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      @expense = Expense.find(params[:id])
      @expense.update(params[:expense])
      @expense.save
      redirect to "/expense/#{@expense.id}"
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  post '/expense/:id/edit' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      @expense = Expense.find(params[:expense_id])
      @categories = Category.categories_of_user(@sessionName)
      binding.pry
      erb :'expense/edit', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect to '/'
    end
  end

  get '/expense/:id' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      @expense = Expense.find(params[:id])
      erb :'expense/show', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect to '/'
    end
  end

  post '/expense/add' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      if (!params[:expense]["date"].empty? &&
          !params[:expense]["amount"].empty? &&
          !params[:expense]["description"].empty? &&
          !params[:expense]["merchant"].empty?)
          @matched_expense = entry_already_exists?(params[:expense])
          if !@matched_expense
            if params[:expense]["date"] > Time.now.to_s(:db)
              flash[:message] = "Invalid date"
              redirect to '/expense/add'
            else
              @expense = Expense.create(params[:expense])
              Expense.all << @expense
              @expense.save
              flash[:message] = "Expense added"
              redirect to "/expense/#{@expense.id}"
            end
          else
            flash[:message] = "Already added"
            redirect to '/expense/add'
          end
      else
        flash[:message] = "Missing Fields"
        redirect to '/expense/add'
      end
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect to '/'
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
