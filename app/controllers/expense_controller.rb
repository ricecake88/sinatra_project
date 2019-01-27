class ExpenseController < ApplicationController

  before do
    #redirect_if_not_logged_in
  end

  get '/expenses' do
    redirect_if_not_logged_in
    Category.create_category_if_empty(session)
    if params[:num_days].nil?
      @num_days = 30
    else
      @num_days = params[:num_days].to_i
    end
    @categories = Category.sort_categories(session)
    @expenses = current_user.expenses.sort_by(&:date).last(@num_days)
    erb :'expenses/index', :layout => :layout_loggedin
  end

  get '/expenses/new' do
    redirect_if_not_logged_in
    Category.create_category_if_empty(session)
    @categories = Category.sort_categories(session)
    erb :'expenses/new', :layout => :layout_loggedin
  end

  post '/expenses' do
    #user = current_user
    #if is_logged_in? && !user.nil?
    redirect_if_not_logged_in
    if (!params[:expense]["date"].empty? &&
        !params[:expense]["amount"].empty? &&
        !params[:expense]["description"].empty? &&
        !params[:expense]["merchant"].empty?)
        if new_entry?(params[:expense])
          redirect_if_invalid_date(params[:expense])
          #if params[:expense]["date"] > Time.now.to_s(:db)
          #  flash[:message] = "Invalid date"
          #  redirect to '/expenses/new'
          #else
            @expense = Expense.new(params[:expense])
            category = current_user.categories.detect { |cat| cat.id == params[:expense]["category_id"].to_i }
            if @expense.save
              @expense.category = category
              Expense.all << @expense
              flash[:message] = "Expense added"
              redirect to "/expenses/#{@expense.id}"
            else
              redirect to '/expenses/new'
            end
          #end
        else
          flash[:message] = "Already added"
          redirect to '/expenses/new'
        end
    else
      flash[:message] = "Missing Fields"
      redirect to '/expenses/new'
    end
    #else
    #  flash[:message] = "Illegal action. Please log-in to access this page."
    #  redirect to '/'
    #end
  end

  get '/expenses/:id/edit' do
    redirect_if_not_logged_in
    @expense = Expense.find(params[:id])
    if current_user == @expense.category.user
      @categories = Category.sort_categories(session)
      erb :'expenses/edit', :layout => :layout_loggedin
    else
      flash[:message] = "You do not have permission to do that."
      redirect to '/'
    end
  end

  patch '/expenses/:id' do
    redirect_if_not_logged_in
    @expense = Expense.find(params[:id])
    # check if expense being updated is owned by the user
    if !@expense.nil? && current_user == @expense.category.user
      if new_entry?(params[:expense])
        redirect_if_invalid_date(params[:expense])
        #if params[:expense]["date"] > Time.now.to_s(:db)
        #  flash[:message] = "Invalid date"
        #  redirect to '/expenses'
        #else
          @expense.update(params[:expense])
          @expense.save
          flash[:message] = "Expense Updated"
          redirect to "/expenses/#{@expense.id}"
        #end
      else
        flash[:message] = "Entry already entered or invalid."
        redirect '/expenses/select'
      end
    else
      flash[:message] = "You do not have permission to do that."
      redirect to '/'
    end
  end

  delete '/expenses/:id' do
    redirect_if_not_logged_in
    @expense = Expense.find_by_id(params[:id])
    # check if expense being deleted is owned by the user
    if @expense && current_user == @expense.category.user
      @expense.delete
      flash[:message] = "Expense Deleted"
      redirect to '/expenses'
    else
      flash[:message] = "You do not have permission to do that."
      redirect to '/'
    end
  end

  get '/expenses/:id' do
    redirect_if_not_logged_in
    @expense = Expense.find_by(:id=>params[:id])
    if @expense
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

    def redirect_if_invalid_date(expense)
      if expense["date"] > Time.now.to_s(:db)
        flash[:message] = "Invalid date"
        redirect to '/expenses'
      end
    end

  end
end
