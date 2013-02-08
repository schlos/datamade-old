require "sinatra/base"
require "sinatra/reloader"
require "sinatra-initializers"
require "sinatra/r18n"

module SiteTemplate
  class Application < Sinatra::Base
    enable :logging, :sessions
    enable :dump_errors, :show_exceptions if development?

    configure :development do
      register Sinatra::Reloader
    end
    
    register Sinatra::Initializers
    register Sinatra::R18n

    before do
      session[:locale] = params[:locale] if params[:locale]
    end

    use Rack::Logger
    use Rack::Session::Cookie

    helpers SiteTemplate::HtmlHelpers

    get "/" do
      cache_control :public, max_age: 3600  # 1 hour
      @current_menu = "home"
      @title = 'DataMade - Tell a story with your data'
      haml :index
    end
    
    # catchall for static pages
    get "/:page/?" do
      cache_control :public, max_age: 3600  # 1 hour
      begin 
        @current_menu = params[:page]
        @title = params[:page].capitalize.gsub(/[_-]/, " ") + " - DataMade"
        @page_path = params[:page]
        haml params[:page].to_sym
      rescue Errno::ENOENT
        haml :not_found
      end
    end
    
    error do
      'Sorry there was a nasty error - ' + env['sinatra.error'].name
    end
  end
end
