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

  disable :sessions
  enable :method_override # enable support for _method in forms, for PUT and DELETE methods
end

LANGUAGES = {
  :plain      => "Plain text",
  :apache     => "Apache",
  :assembler  => "Assembler",
  :avrasm     => "AVR Assembler",
  :axapta     => "Axapta",
  :bash       => "Bash",
  :c          => "C",
  :cs         => "C#",
  :cpp        => "C++",
  :cmake      => "CMake",
  :css        => "CSS",
  :delphi     => "Delphi",
  :diff       => "Diff",
  :django     => "Django",
  :dos        => "DOS batch file",
  :erlang     => "Erlang",
  :erlang_repl=> "Erlang REPL",
  :go         => "Go",
  :haskell    => "Haskell",
  :html       => "HTML",
  :ini        => "Ini",
  :java       => "Java",
  :javascript => "Javascript",
  :lisp       => "Lisp",
  :lua        => "Lua",
  :mel        => "MEL",
  :nginx      => "Nginx",
  :objective  => "Objective",
  :parser3    => "Parser3",
  :perl       => "Perl",
  :php        => "PHP",
  :profile    => "Python profiler",
  :python     => "Python",
  :ruby       => "Ruby",
  :scala      => "Scala",
  :smalltalk  => "Smalltalk",
  :sql        => "SQL",
  :tex        => "TeX",
  :vala       => "Vala",
  :vbscript   => "VBScript",
  :vhdl       => "VHDL",
  :xml        => "XML"
}

require 'pastest/dm-session'
require 'pastest/paste'
DataMapper.finalize

use Rack::Session::DataMapper

helpers do
  def title str=''
    @title = "pastest - #{str}" unless str.empty?
  end
end

before do
  session[:pastes] ||= []

  @title = "pastest"
end

get '/', :provides => :html do
  @languages = LANGUAGES
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

  @is_owner = session[:pastes].include? @paste.id
  title @id
  haml :paste
end

post '/', :provides => :html do
  @paste = Paste.new params[:paste]
  if @paste.save
    session[:pastes] << @paste.id
    redirect to("/#{@paste.id}")
  else
    redirect to('/')
  end
end
