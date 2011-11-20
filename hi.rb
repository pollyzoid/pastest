require 'rubygems'
require 'sinatra'

get '/' do
	"Hello, World!"
end

get '/hi' do
  "Hi!"
end