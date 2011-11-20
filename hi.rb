require 'rubygems'
require 'sinatra'

get '/' do
	"Hello, World!"
end

get '/accept' do
	request.accept
end