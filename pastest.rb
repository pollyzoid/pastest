require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'
require 'dm-timestamps'
require 'securerandom'

$: << File.join(File.dirname(__FILE__), 'lib')

DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/postgres')

require 'pastest/paste'

DataMapper.finalize

set :haml, :format => :html5
set :haml, :escape_html => true

get '/', :provides => :html do
  @recent = Paste.public.sorted.recent 20
  haml :index
end

get '/:id', :provides => :html do |id|
  @id = id

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
