require_dependency "headlines/application_controller"

module Headlines
  class HeadlinesController < ApplicationController
    
    before_filter :head_only_author, :except => [:index,:show,:options]
    before_filter :set_access_control_headers

    def options
      head :ok
    end

    def index
      
    end
    
    def new
      @headline = Headline.new params[:headline]
    end
    
    def create
      @headline = Headline.new params[:headline]      
    end

    def set_access_control_headers
      headers['Access-Control-Allow-Origin']      = request.env['HTTP_ORIGIN'] || "*"
      headers['Access-Control-Allow-Methods']     = 'POST, GET, OPTIONS'
      headers['Access-Control-Max-Age']           = '1000'
      headers['Access-Control-Allow-Headers']     = 'x-requested-with,content-type,X-CSRF-Token'
      headers['Access-Control-Allow-Credentials'] = "true"      
    end
  end
end
