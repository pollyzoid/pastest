require 'rubygems'
require 'sinatra'

get '/' do
	"Hello, World!"
end

get '/accept', :provides => :html do
	"html"
end

get '/accept', :provides => :json do
	"json"
end