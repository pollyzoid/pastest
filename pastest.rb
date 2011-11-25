require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'dm-core'
require 'dm-aggregates'
require 'dm-timestamps'
require 'securerandom'

configure do
  $: << File.join(File.dirname(__FILE__), 'lib')

  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://postgres:nope@localhost/postgres')

  set :haml, :format => :html5
  set :haml, :escape_html => true

  disable :sessions
  enable :method_override # enable support for _method in forms, for PUT and DELETE methods
end

LANGUAGES = {
  :plain      => "Plain text",
  :'1c'       => "1C",
  :apache     => "Apache",
  :avrasm     => "AVR Assembler",
  :axapta     => "Axapta",
  :bash       => "Bash",
  :cs         => "C#",
  :cpp        => "C++",
  :cmake      => "CMake",
  :css        => "CSS",
  :delphi     => "Delphi",
  :diff       => "Diff",
  :django     => "Django",
  :dos        => "DOS .bat",
  :erlang     => "Erlang",
  :erlang_repl=> "Erlang REPL",
  :go         => "Go",
  :haskell    => "Haskell",
  :ini        => "Ini",
  :java       => "Java",
  :javascript => "Javascript",
  :lisp       => "Lisp",
  :lua        => "Lua",
  :mel        => "MEL",
  :nginx      => "Nginx",
  :objectivec => "Objective C",
  :parser3    => "Parser3",
  :perl       => "Perl",
  :php        => "PHP",
  :python     => "Python",
  :profile    => "Python profiler",
  :rsl        => "RenderMan RSL",
  :rib        => "RenderMan RIB",
  :ruby       => "Ruby",
  :scala      => "Scala",
  :smalltalk  => "Smalltalk",
  :sql        => "SQL",
  :tex        => "TeX",
  :vala       => "Vala",
  :vbscript   => "VBScript",
  :vhdl       => "VHDL",
  :xml        => "XML, HTML"
}

require 'pastest/dm-session'
require 'pastest/paste'
DataMapper.finalize

use Rack::Session::DataMapper

helpers do
  def title str=''
    @title = "pastest - #{str}" unless str.empty?
  end
  def versioned_sass ss
    url "/styles/#{ss}.css?" + File.mtime(File.join(settings.views, "styles", "#{ss}.sass")).to_i.to_s
  end
  def versioned_js js
    url "/scripts/#{js}.js?" + File.mtime(File.join(settings.public_folder, "scripts", "#{js}.js")).to_i.to_s
  end
end

before do
  session[:pastes] ||= []

  @title = "pastest"
end

get '/styles/stylesheet.css' do
  content_type 'text/css'
  response['Expires'] = (Time.now + 60*30).httpdate
  sass :"styles/stylesheet"
end

get '/', :provides => :html do
  @languages = LANGUAGES
  
  haml :index
end

get '/pastes', :provides => :html do
  @recent = Paste.public.sorted.recent 200

  # some stats
  @num_total = Paste.count
  @num_private = Paste.count(:private => true)
  @num_recent = @recent.length

  haml :pastes
end

get '/pastes/:id', :provides => :html do |id|
  @id = id
  @paste = Paste.get(@id)

  if @paste.nil?
    title '404'
    halt 404, haml(:nopaste)
  end

  @is_owner = session[:pastes].include? @paste.id
  title @id
  haml :paste
end

post '/pastes', :provides => :html do
  # welp
  unless LANGUAGES.key? :"#{params[:paste][:language]}" # what the fuck
    redirect to('/')
  end

  @paste = Paste.new params[:paste]
  if @paste.save
    session[:pastes] << @paste.id
    redirect to("/pastes/#{@paste.id}")
  else
    redirect to('/')
  end
end
