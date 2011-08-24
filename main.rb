require 'sinatra/base'
require 'haml'
require 'data_mapper'

class DeckTheHalls < Sinatra::Base
  # Load Helpers
  Dir["./helpers/*.rb"].each do |file|
    require file
    helpers Kernel.const_get(file.gsub(%r{(./helpers/|.rb)},'').capitalize)
  end
  
  # Load Models
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite:data")
  Dir["./models/*"].each {|file| require file }
  DataMapper.finalize
  DataMapper.auto_upgrade!

  enable :sessions
  set :public, './public'

  get '/' do
    haml :index
  end
  
  post '/new' do
    presentation = Presentation.create(params[:presentation])
    redirect "/pres/#{presentation.id}"
  end
  
  get '/pres/:id' do
    @presentation = Presentation.get(params[:id])
    haml :presentation
  end
end