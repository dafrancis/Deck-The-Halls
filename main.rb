require 'sinatra/base'
require 'sinatra/reloader'
require 'haml'
require 'data_mapper'
require 'rdiscount'

class DeckTheHalls < Sinatra::Base
  use Rack::MethodOverride
  # Load Helpers
  Dir["./helpers/*.rb"].each do |file|
    require file
    helpers Kernel.const_get(file.gsub(%r{(./helpers/|.rb)},'').capitalize)
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
  
  # Load Models
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite:data")
  Dir["./models/*"].each {|file| require file }
  DataMapper.finalize
  DataMapper.auto_upgrade!

  enable :sessions
  set :public_folder, './public'

  get '/' do
    haml :index
  end
  
  post '/new' do
    presentation = Presentation.create!(params[:presentation])
    redirect "/pres/#{presentation.id}"
  end  
  
  get '/pres/slide/new/:id' do
    haml :new_slide
  end
  
  post '/pres/slide/new' do
    slide = Presentation.get(params[:pres]).slides.create(params[:slide])
    redirect "/pres/#{params[:pres]}"
  end
  
  post '/pres/slide/edit' do
    slide = Slide.first(:id => params[:slide])
    slide.content = params[:content]
    slide.save
    redirect "/pres/#{slide.presentation.id}"
  end
  
  get '/pres/slide/:id' do
    @slide = Slide.first(:id => params[:id])
    haml :edit_slide
  end
  
  delete '/pres/slide/:id' do
    slide = Slide.first(:id => params[:id])
    pres = slide.presentation
    slide.destroy
    redirect "/pres/#{pres.id}"
  end
  
  get '/pres/view/:id' do
    @presentation = Presentation.get(params[:id])
    erb :presentation
  end
  
  get '/pres/:id' do
    @presentation = Presentation.get(params[:id])
    haml :presentation
  end
  
  delete '/pres/:id' do
    pres = Presentation.get(params[:id])
    pres.destroy!
    redirect "/"
  end
end
