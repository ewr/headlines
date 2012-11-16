module Headlines
  class ApplicationController < ::ApplicationController
    layout Headlines::Config.layout
    
    def head_only_author
      if !@current_user || !@current_user.author?
        flash[:notice] = "Author rights are required."
        redirect_to headlines_path and return
      end
    end
  end
end
