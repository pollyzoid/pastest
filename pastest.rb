require 'rubygems'
require 'sinatra'
require 'haml'
require 'data_mapper'
require 'json'

#DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

set :haml, :format => :html5

pastes = []

get '/', :provides => :html do
  haml :index
end

get '/:id', :provides => :html do |id|
  @id = id
  haml :paste
end

post '/' do

end

delete '/' do

end