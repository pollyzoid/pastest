require 'rubygems'
require 'sinatra'
require 'haml'
require 'data_mapper'
require 'json'

#DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

pastes = []

get '/' do
  haml :index
end

get '/pastes', :provides => :json do
	request.accept.to_json
end

get '/accept', :provides => :html do
	"<strong>blah</strong>"
end

get '/accept', :provides => :json do
	"json"
end