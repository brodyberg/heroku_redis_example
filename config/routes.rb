ActionController::Routing::Routes.draw do |map|
  map.trogdor 'trogdor/burninate/:target', :controller => 'trogdor', :action => 'burninate'
end
