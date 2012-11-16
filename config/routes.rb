Headlines::Engine.routes.draw do
  match '/', :controller => 'headlines', :action => 'options', :constraints => {:method => 'OPTIONS'}
  resources :headlines, :path => ''
end
