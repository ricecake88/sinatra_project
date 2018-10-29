#require 'sinatra'
require './config/environment'
require_relative 'app/controllers/expense_controller'
require_relative 'app/controllers/category_controller'
require_relative 'app/controllers/budget_controller'
#require_relative './app.rb'

use Rack::MethodOverride
use ExpenseController
use CategoryController
use BudgetController
run ApplicationController
