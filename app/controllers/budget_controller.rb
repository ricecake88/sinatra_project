class BudgetController < ApplicationController

  get '/budgets' do
    redirect_if_not_logged_in
    @budgets = current_user.budgets
    @categories = current_user.categories
    erb :'budgets/index', :layout => :layout_loggedin
  end

  get '/budgets/new' do
    redirect_if_not_logged_in
    Category.create_category_if_empty(session)
    @categories = current_user.categories_sorted
    erb :'/budgets/new', :layout => :layout_loggedin
  end

  get '/budgets/:id/edit' do
    redirect_if_not_logged_in
    @budget = Budget.find_by(:id => params[:id])
    redirect_if_not_valid_record(@budget)
    @categories = current_user.categories_sorted
    erb :'/budgets/edit', :layout => :layout_loggedin
  end

  get '/budgets/:id' do
    redirect_if_not_logged_in
    @budget = Budget.find_by(:id => params[:id])
    redirect_if_not_valid_record(@budget)
    @categories = Helpers.current_user(session).categories
    erb :'/budgets/show', :layout => :layout_loggedin
  end

  post '/budgets/create' do
    redirect_if_not_logged_in
    if cat_exists?(params[:budget]['category'])
      flash[:message] = "OOPS, already set a budget for this category. "
      redirect to "/budgets"
    elsif params[:budget]["amount"].to_d < 0
      flash[:message] = "Error, budget amount must not be negative."
      redirect to "/budgets"
    elsif !params[:budget]["amount"].empty? && !params[:budget]["category"].empty?
      @budget = Budget.new(:category_id => params[:budget]["category"].to_i, :amount => params[:budget]["amount"], :rollover => params[:budget]["rollover"])
      if @budget.save
        @budget.category.budget = @budget
        Budget.all << @budget
        redirect to "/budgets/#{@budget.id}"
      else
        flash[:message] = "You do not have permission to do that."
        redirect to '/'
      end
    else
      flash[:message] = "Sorry, either the amount or category entered is empty"
      redirect to "/budgets/add"
    end
  end

patch '/budgets/:id/edit' do
  redirect_if_not_logged_in
  @budget = Budget.find_by(:id => params[:id])
  redirect_if_not_valid_user_or_record(@budget)
  @budget.update(:amount => params[:amount], :rollover => params[:rollover])
  @budget.save
  redirect to '/budgets'
end

delete '/budgets/:id/delete' do
  redirect_if_not_logged_in
  @budget = Budget.find_by(:id => params[:id])
  redirect_if_not_valid_user_or_record(@budget)
  @budget.delete
  flash[:message] = "Budget Deleted"
  redirect to '/budgets'
end

  helpers do
    def cat_exists?(cat_id)
      Budget.find_by(:category_id => cat_id.to_i)
    end
  end

end
