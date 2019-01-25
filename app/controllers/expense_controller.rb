class ExpenseController < ApplicationController

  before do
    :redirect_if_not_logged_in
  end

  get '/expenses' do
    user = current_user
    if is_logged_in? && !user.nil?
      Category.create_category_if_empty(session)
      if params[:num_days].nil?
        @num_days = 30
      else
        @num_days = params[:num_days].to_i
      end
      @categories = Category.sort_categories(session)
      @expenses = user.expenses.sort_by(&:date).last(@num_days)
      erb :'expenses/index', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  get '/expenses/new' do
    user = current_user
    if is_logged_in? && !user.nil?
      Category.create_category_if_empty(session)
      @categories = Category.sort_categories(session)
      erb :'expenses/new', :layout => :layout_loggedin
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  post '/expenses' do
    user = current_user
    if is_logged_in? && !user.nil?
      if (!params[:expense]["date"].empty? &&
          !params[:expense]["amount"].empty? &&
          !params[:expense]["description"].empty? &&
          !params[:expense]["merchant"].empty?)
          if new_entry?(params[:expense])
            if params[:expense]["date"] > Time.now.to_s(:db)
              flash[:message] = "Invalid date"
              redirect to '/expenses/new'
            else
              @expense = Expense.new(params[:expense])
              category = user.categories.detect { |cat| cat.id == params[:expense]["category_id"].to_i }
              if @expense.save
                @expense.category = category
                Expense.all << @expense
                flash[:message] = "Expense added"
                redirect to "/expenses/#{@expense.id}"
              else
                redirect to '/expenses/new'
              end
            end
          else
            flash[:message] = "Already added"
            redirect to '/expenses/new'
          end
      else
        flash[:message] = "Missing Fields"
        redirect to '/expenses/new'
      end
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect to '/'
    end
  end

  get '/expenses/:id/edit' do
    user = current_user
    if is_logged_in? && !user.nil?
      if params[:id]
        @expense = Expense.find(params[:id])
        if user == @expense.category.user
          @categories = Category.sort_categories(session)
          erb :'expenses/edit', :layout => :layout_loggedin
        else
          flash[:message] = "You do not have permission to do that."
          redirect to '/'
        end
      end
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect to '/'
    end
  end

  patch '/expenses/:id' do
    user = current_user
    if is_logged_in? && !user.nil?
      @expense = Expense.find(params[:id])
      # check if expense being updated is owned by the user
      if !@expense.nil? && user == Category.find(@expense.category_id).user
        if new_entry?(params[:expense])
          if params[:expense]["date"] > Time.now.to_s(:db)
            flash[:message] = "Invalid date"
            redirect to '/expenses'
          else
            @expense.update(params[:expense])
            @expense.save
            flash[:message] = "Expense Updated"
            redirect to "/expenses/#{@expense.id}"
          end
        else
          flash[:message] = "Entry already entered or invalid."
          redirect '/expenses/select'
        end
      else
        flash[:message] = "You do not have permission to do that."
        redirect to '/'
      end
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect '/'
    end
  end

  delete '/expenses/:id' do
    user = current_user
    if is_logged_in? && !user.nil?
      @expense = Expense.find_by_id(params[:id])
      # check if expense being deleted is owned by the user
      if @expense && user == Category.find(@expense.category_id).user
        @expense.delete
        flash[:message] = "Expense Deleted"
        redirect to '/expenses'
      else
        flash[:message] = "You do not have permission to do that."
        redirect to '/'
      end
    else
      flash[:message] = "Illegal action. Please log-in to access this page."
      redirect to '/'
    end
  end

  get '/expenses/:id' do
    #redirect_if_not_logged_in
    @expense = Expense.find(params[:id])
    if !@expense.nil?
      @categories = current_user.categories_sorted
      erb :'expenses/show', :layout => :layout_loggedin
    else
      flash[:message] = "Expense not found."
      redirect to '/expenses'
    end
  end

  helpers do

    def new_entry?(expense)
      @matched_expense = Expense.find_by(:date => expense['date'], :category_id => expense['category_id'], :amount => expense[:amount], :merchant => expense[:merchant])
      @matched_expense.nil?
    end
  end
end
