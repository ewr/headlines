module Headlines
  class Config
    @@config = {
      "user_model" => nil,
      "asset_model" => "AssetHostCore::Asset",
      "server" => nil,
      "layout" => "application",
      "path" => nil #Headlines::Engine.mounted_path
    }
    
    class << self
      @@config.keys.each do |f|
        define_method f do |input=nil|
          @@config[f] = input if input
          @@config[f]
        end
      end
    end
  end
end