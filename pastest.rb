require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'
require 'dm-timestamps'
require 'securerandom'

configure do
  $: << File.join(File.dirname(__FILE__), 'lib')

  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://postgres:nope@localhost/postgres')

  set :haml, :format => :html5
  set :haml, :escape_html => true
end

require 'pastest/paste'
DataMapper.finalize

helpers do
  def title(str='')
    @title = str.empty? ? "pastest" : "pastest - #{str}"
  end
end

get '/', :provides => :html do
  @recent = Paste.public.sorted.recent 20
  haml :index
end

get '/:id', :provides => :html do |id|
  @id = id
  @paste = Paste.get(@id)

  if @paste.nil?
    title '404'
    halt 404, haml(:nopaste)
  end

  title @id
  haml :paste
end

post '/', :provides => :html do
  @paste = Paste.new params[:paste]
  if @paste.save
    redirect "/#{@paste.id}"
  else
    redirect "/"
  end  
end
