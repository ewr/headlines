module Headlines
  class Engine < ::Rails::Engine
    isolate_namespace Headlines
    @@mpath = nil
    
    def self.mounted_path
      if @@mpath
        return @@mpath.spec.to_s == '/' ? '' : @@mpath.spec.to_s
      end
      
      # -- find our path -- #
      
      route = Rails.application.routes.routes.detect { |route| route.app == self }
        
      if route
        @@mpath = route.path
      end

      return @@mpath.spec.to_s == '/' ? '' : @@mpath.spec.to_s
    end
  end
end
