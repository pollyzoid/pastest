require 'rubygems'
require 'sinatra'
require 'haml'
require 'data_mapper'
require 'json'

$: << File.join(File.dirname(__FILE__), 'lib')
require 'pastest/paste'

#DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

set :haml, :format => :html5
set :haml, :escape_html => true

pastes = Array.new

get '/', :provides => :html do
  @pastes = pastes
  haml :index
end

get '/:id', :provides => :html do |id|
  @id = id.to_i

  halt 404, haml(:nopaste) if pastes[@id-1].nil?

  @paste = pastes[@id-1]

  haml :paste
end

post '/', :provides => :html do
  pastes << Paste.new(pastes.count + 1, params[:body])
  redirect "/#{pastes.count}"
end

delete '/' do

end