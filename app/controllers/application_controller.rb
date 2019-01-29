require_relative '../../config/environment'
require 'rack-flash'

class ApplicationController < Sinatra::Base

  configure do
    use Rack::Flash
    enable :sessions

    register Sinatra::ActiveRecordExtension
    set :session_secret, "my_application_secret"
    set :views, Proc.new { File.join(root, "../views/") }
    set :public_folder, 'public'
  end

  get '/' do
    erb :'index'
  end

  get '/signup' do
    erb :'signup'
  end

  post '/signup' do
    if params[:username].empty? || params[:password].empty?
      flash[:message] = "Sorry, username or password field missing."
    elsif invalid_username(params[:username])
      flash[:message] = "Invalid Username. Please Enter a valid username with length of 4 to 16 lowercase letters and numbers only with "_" allowed."
    elsif username_exists?(params[:username])
      flash[:message] = "Username already exists."
    else
      @user = User.new(username: params[:username], password: params[:password])
      if @user.save
        flash[:message] = "Account created. Please sign in!"
        redirect '/'
      else
        flash[:message] = "Unknown error. Please try again."
      end
    end
    redirect '/signup'
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect '/account'
    else
      flash[:message] = "Sorry, username/password combination does not exist."
      redirect '/'
    end
  end

  get '/account' do
    redirect_if_not_logged_in
    @user = current_user
    @budget_hashes = []
    @categories = current_user.categories_sorted
    @total_month_expense = current_user.total_current_month
    @expenses_current_month = current_user.specific_month_expenses(Helpers.current_year, Helpers.current_month)
    @categories.each do |cat|
      budget_hash = @user.surplus_for_category(cat.id)
      @budget_hashes << budget_hash
    end
    erb :account, :layout => :layout_loggedin
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  helpers do
    def username_exists?(username)
      !User.find_by(:username => username).nil?
    end

    def invalid_username(username)
      result = username =~ /\A[a-z0-9_]{4,16}\z/
      result.nil?
    end

    def current_user
        @current_user ||= User.find_by(:id => session[:user_id])
    end

    def is_logged_in?
      !!current_user
    end

    def redirect_if_not_logged_in
      if !is_logged_in?
        flash[:message] = "Illegal action. Please log-in to access this page."
        redirect '/'
      end
    end

    def redirect_if_not_valid_record(record, type)
      if record.nil?
        flash[:message] = "#{type} not found."
        redirect "/#{type.downcase}s"
      end
    end

    # record must be of one of the types, otherwise it is implied that it does
    # not exist and will return false. If it does exist, it validates the
    # user is authorized to make a change to the record
    def redirect_if_not_valid_user_or_record(record)
      valid = false
      if ((record.class == Budget || record.class == Expense) && record.category.user == current_user) ||
         (record.class == Category && record.user == current_user)
        valid = true
      end
      if !valid
        flash[:message] = "You do not have permission to do that."
        redirect '/'
      end
    end
  end
end
