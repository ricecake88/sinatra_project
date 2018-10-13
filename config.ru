#require 'sinatra'
require './config/environment'
require_relative 'app/controllers/expense_controller'
#require_relative './app.rb'

use Rack::MethodOverride
use ExpenseController
run ApplicationController