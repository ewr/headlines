module Headlines
  class Headline < ActiveRecord::Base
    attr_accessible :title, :url, :intro, :excerpt
    
    validates_presence_of :title, :url, :intro, :user
    
    belongs_to :user, :class_name => Headlines::Config.user_model
    belongs_to :asset, :class_name => Headlines::Config.asset_model
    
  end
end
