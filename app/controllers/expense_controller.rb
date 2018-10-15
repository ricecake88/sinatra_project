require 'sinatra/reloader'

class ExpenseController < ApplicationController
    configure :development do
        register Sinatra::Reloader
    end

    get '/expense' do
        erb :'expense/index'
    end
end