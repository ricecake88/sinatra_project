class BudgetController < ApplicationController

  get '/budgets' do
    redirect_if_not_logged_in
    erb :'budgets/index', :layout => :layout_loggedin
  end

  get '/budgets/new' do
    redirect_if_not_logged_in
    Category.create_category_if_empty(current_user)
    erb :'/budgets/new', :layout => :layout_loggedin
  end

  get '/budgets/:id/edit' do
    redirect_if_not_logged_in
    @budget = Budget.find_by(:id => params[:id])
    redirect_if_not_valid_user_or_record(@budget)
    erb :'/budgets/edit', :layout => :layout_loggedin
  end

  get '/budgets/:id' do
    redirect_if_not_logged_in
    @budget = Budget.find_by(:id => params[:id])
    redirect_if_not_valid_user_or_record(@budget)
    erb :'/budgets/show', :layout => :layout_loggedin
  end

  post '/budgets/create' do
    redirect_if_not_logged_in
    redirect_if_invalid_budget(params[:budget], '/budgets/new')
    @budget = Budget.new(:category_id => params[:budget]["category"].to_i, :amount => params[:budget]["amount"], :rollover => params[:budget]["rollover"])
    if @budget.save
      flash[:message] = "Budget Added."
      redirect to "/budgets/#{@budget.id}"
    end
  end

  patch '/budgets/:id/edit' do
    redirect_if_not_logged_in
    redirect_if_invalid_budget(params[:budget], '/budgets')
    @budget = Budget.find_by(:id => params[:id])
    redirect_if_not_valid_user_or_record(@budget)
    @budget.update(:amount => params[:amount], :rollover => params[:rollover])
    flash[:message] = "Budget Updated."
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

    def redirect_if_invalid_budget(budget_fields, path)
      valid = false
      if budget_fields.has_value?("")
        flash[:message] = "Sorry, the amount is empty."
      elsif cat_exists?(budget_fields['category'])
        flash[:message] = "OOPS, already set a budget for this category. "
      elsif budget_fields['amount'].to_d < 0
        flash[:message] = "Error, budget amount must not be negative."
      else
        valid = true
      end
      if !valid
        redirect to path
      end
    end
  end

end
