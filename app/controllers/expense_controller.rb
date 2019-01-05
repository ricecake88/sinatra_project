require 'rack-flash'

class ExpenseController < ApplicationController
  use Rack::Flash
  enable :sessions

  set :public_folder, 'public'
  get '/expense' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      user = Helpers.current_user(@sessionName)
      @expenses = user.expenses.sort_by(&:date).last(30)
      erb :'expense/index', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/expense/add' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      Category.create_category_if_empty(@sessionName)
      erb :'expense/add', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/expense/select' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      @expenses = Helpers.current_user(@sessionName).expenses.sort_by(&:date).last(30)
      erb :'expense/select', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page/"
      redirect '/'
    end
  end

  get '/expense/display/:num' do
    @sessionName = session
    if Helpers.is_logged_in?(session)
      user = Helpers.current_user(@sessionName)
      @expenses = user.expenses.sort_by(&:date).last(params[:num].to_i)
      erb :'expense/index', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  patch '/expense/:id' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      @expense = Expense.find(params[:id])
      @id = params[:id]
      if new_entry?(params[:expense])
        if params[:expense]["date"] > Time.now.to_s(:db)
          flash[:message] = "Invalid date"
          redirect to "/expense/select"
        else
          @expense.update(params[:expense])
          @expense.save
          flash[:message] = "Expense Updated"
          redirect to "/expense/#{@expense.id}"
        end
      else
        flash[:message] = "Entry already entered or invalid."
        redirect '/expense/select'
      end
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  post '/expense/:id/edit' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      if (!params[:expense_id].nil?)
        @expense = Expense.find(params[:expense_id])
        #@categories = Helpers.current_user(session).categories
        if params[:Button] == "Edit"
          erb :"expense/#{@id}/edit", :layout => :layout_loggedin
        elsif params[:Button] == "Delete"
          erb :"expense/#{@id}/delete", :layout => :layout_loggedin
        end
      else
        flash[:message] = "No Expense Selected"
        redirect to '/expense/select'
      end
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect to '/'
    end
  end

  get '/expense/:id/delete' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      @expense = Expense.find(params[:id])
      erb :"expense/delete", :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page/"
      redirect '/'
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

  post '/expense' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      @num_days = params[:num_days]
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect to '/'
    end
    redirect to "/expense/display/#{@num_days}"
  end

  post '/expense/add' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      if (!params[:expense]["date"].empty? &&
          !params[:expense]["amount"].empty? &&
          !params[:expense]["description"].empty? &&
          !params[:expense]["merchant"].empty?)
          if new_entry?(params[:expense])
            if params[:expense]["date"] > Time.now.to_s(:db)
              flash[:message] = "Invalid date"
              redirect to '/expense/add'
            else
              @expense = Expense.new(params[:expense])
              user = Helpers.current_user(@sessionName)
              @expense.user = user
              user.expenses << @expense
              if @expense.save
                Expense.all << @expense
                flash[:message] = "Expense added"
                redirect to "/expense/#{@expense.id}"
              else
                redirect to '/expense/add'
              end
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

  delete '/expense/:id/delete' do
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      @expense = Expense.find_by_id(params[:id])
      if @expense
        @expense.delete
      end
      flash[:message] = "Expense Deleted"
      redirect to '/expense'
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect to '/'
    end
  end

  helpers do

    def new_entry?(expense)
      @matched_expense = Expense.find_by(:date => expense['date'], :category_id => expense['category_id'], :user_id => session[:user_id], :amount => expense[:amount], :merchant => expense[:merchant])
      if @matched_expense.nil?
        return true
      else
        return false
      end
    end
  end
end
