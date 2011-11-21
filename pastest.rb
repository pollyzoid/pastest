require 'rubygems'
require 'sinatra'
require 'haml'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

$: << File.join(File.dirname(__FILE__), 'lib')
require 'pastest/paste'

DataMapper.finalize

set :haml, :format => :html5
set :haml, :escape_html => true

get '/', :provides => :html do
  @recent = Paste.all(:limit => 5)
  haml :index
end

get '/:id', :provides => :html do |id|
  @id = id.to_i

  @paste = Paste.get(@id)
  halt 404, haml(:nopaste) if @paste.nil?

  haml :paste
end

post '/', :provides => :html do
  @paste = Paste.create(
    :body => params[:body]
  )
  redirect "/#{@paste.id}"
end