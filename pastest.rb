require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'

DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/postgres')

$: << File.join(File.dirname(__FILE__), 'lib')
require 'pastest/paste'

DataMapper.finalize

set :haml, :format => :html5
set :haml, :escape_html => true

get '/', :provides => :html do
  @recent = Paste.all(:limit => 5).reverse
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