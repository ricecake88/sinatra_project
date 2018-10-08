#require 'sinatra'
require './config/environment'

#require_relative './app.rb'

use Rack::MethodOverride
run ApplicationController