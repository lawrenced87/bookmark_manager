require 'sinatra/base'
require_relative 'data_mapper_setup.rb'


ENV["RACK_ENV"] ||= "development"

class Bookmark < Sinatra::Base

enable :sessions
set :session_secret, 'super secret'

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  get '/links' do
    @links = Link.all
    erb :'links/index'
  end

  get '/links/new' do
    erb :'links/new'
  end

  get '/signup' do
    erb :'/signup'
  end

  post '/sign-up' do
    new_user = User.create(:username => params[:username], :email => params[:email], :password_digest => password=(params[:password]))
    session[:user_id] = new_user.id
    redirect '/welcome'
  end

  get '/welcome' do
    erb :welcome
  end

  post '/add-link' do
    link = Link.new(:title => params[:title], :url => params[:url])

    all_tags = params[:tag].split(" ")
    all_tags.each do |tag|
      link.tags << Tag.first_or_create(:name => tag)
    end
    link.save
    redirect '/links'
  end

  get '/tags/:name' do
    tag = Tag.first(name: params[:name])
    @links = tag ? tag.links : []
    erb :'links/index'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
