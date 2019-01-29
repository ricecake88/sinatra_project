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
    redirect_if_not_logged_in
    if !params[:expense].has_value?("")
        if new_entry?(params[:expense])
          redirect_if_invalid_date(params[:expense])
          @expense = Expense.new(params[:expense])
          if @expense.save
            Expense.all << @expense
            flash[:message] = "Expense added"
            redirect to "/expenses/#{@expense.id}"
          end
        else
          flash[:message] = "Already added"
        end
    else
      flash[:message] = "Missing Fields"
    end
    redirect to '/expenses/new'
  end

  get '/expenses/:id/edit' do
    redirect_if_not_logged_in
    @expense = Expense.find(params[:id])
    redirect_if_not_valid_user_or_record(@expense)
    @categories = Category.sort_categories(session)
    erb :'expenses/edit', :layout => :layout_loggedin
  end

  patch '/expenses/:id' do
    redirect_if_not_logged_in
    @expense = Expense.find(params[:id])
    # check if expense being updated is owned by the user
    redirect_if_not_valid_user_or_record(@expense)
    if new_entry?(params[:expense])
      redirect_if_invalid_date(params[:expense])
      @expense.update(params[:expense])
      @expense.save
      flash[:message] = "Expense Updated"
      redirect to "/expenses/#{@expense.id}"
    else
      flash[:message] = "Entry already entered or invalid."
      redirect '/expenses/select'
    end
  end

  delete '/expenses/:id' do
    redirect_if_not_logged_in
    @expense = Expense.find_by_id(params[:id])
    # check if expense being deleted is owned by the user
    redirect_if_not_valid_user_or_record(@expense)
    @expense.delete
    flash[:message] = "Expense Deleted"
    redirect to '/expenses'
  end

  get '/expenses/:id' do
    redirect_if_not_logged_in
    @expense = Expense.find_by(:id=>params[:id])
    redirect_if_not_valid_record(@expense, "Expense")
    @categories = current_user.categories_sorted
    erb :'expenses/show', :layout => :layout_loggedin
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
