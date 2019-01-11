require_relative '../../config/environment'
require 'rack-flash'

class ApplicationController < Sinatra::Base
  use Rack::Flash
  enable :sessions

  register Sinatra::ActiveRecordExtension
  set :session_secret, "my_application_secret"
  set :views, Proc.new { File.join(root, "../views/") }
  set :public_folder, 'public'

  get '/' do
    erb :'index'
  end

  get '/signup' do
    erb :'signup'
  end

  post '/signup' do
    if params[:username].empty? || params[:password].empty?
      flash[:message] = "Sorry, username or password field missing."
      redirect '/signup'
    elsif !validate_user(params[:username])
      flash[:message] = 'Invalid Username. Please Enter a valid username with length of 4 to 16 lowercase letters and numbers only with "_" allowed. '
      redirect '/signup'
    elsif username_exists?(params[:username])
      flash[:message] = "Username already exists."
      redirect '/signup'
    else
      @user = User.new(username: params[:username], password: params[:password])
      if @user.save
        flash[:message] = "Account created. Please sign in!"
        redirect '/'
      end
    end
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
    @sessionName = session
    if Helpers.is_logged_in?(@sessionName)
      @budget_hashes = []
      @user = Helpers.current_user(session)
      @categories = Category.sort_categories(session)
      @total_month_expense = Expense.total_current_month(session)
      @expenses_current_month = Expense.expenses_current_month(Helpers.current_year, Helpers.current_month, @sessionName)
      @categories.each do |cat|
        budget_hash = Budget.surplus_for_category(session, cat.id)
        @budget_hashes << budget_hash
      end
      erb :account, :layout => :layout_loggedin
    else
      flash[:message] = "Sorry you are not logged in."
      redirect '/'
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  helpers do
    def username_exists?(username)
      if (User.find_by(:username => username)).nil?
        false
      else
        true
      end
    end

    def validate_user(username)
      result = username =~ /\A[a-z0-9_]{4,16}\z/
      if result.nil?
        false
      else
        true
      end
    end
  end
end
