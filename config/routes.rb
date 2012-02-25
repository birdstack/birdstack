ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  #map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.

  map.connect '/world-bird-list/', :controller => 'ioc', :action => 'index'
  map.ioc_search '/world-bird-list/search', :controller => 'ioc', :action => 'search'
  map.ioc_alternate_name '/world-bird-list/alternate-name/:name', :controller => 'ioc', :action => 'alternate_name'
  map.connect '/world-bird-list/:order', :controller => 'ioc', :action => 'order'
  map.connect '/world-bird-list/:order/:family', :controller => 'ioc', :action => 'family'
  map.connect '/world-bird-list/:order/:family/:genus', :controller => 'ioc', :action => 'genus'
  map.connect '/world-bird-list/:order/:family/:genus/:species', :controller => 'ioc', :action => 'species'
  
  # Map trip, lists, and location to the /people hierarchy
  map.connect '/trip', :controller => 'redirect', :action => 'people', :peoplecontroller => 'trips', :peopleaction => nil
  map.connect '/location', :controller => 'redirect', :action => 'people', :peoplecontroller => 'locations', :peopleaction => nil
  map.connect '/sighting', :controller => 'redirect', :action => 'people', :peoplecontroller => 'lists', :peopleaction => nil
  map.connect '/friends', :controller => 'redirect', :action => 'people', :peoplecontroller => 'friends', :peopleaction => nil

  map.observations_tags '/people/:user/observations/tags', :controller => 'tags', :action => 'observations_tags'
  # Note that we have to include the special requirements clause so that the tags field can contain periods or slashes
  map.observations_tag '/people/:user/observations/tags/:id', :controller => 'tags', :action => 'observations_tag', :requirements => { :id => /.*/ }
  map.lists '/people/:user/lists', :controller => 'lists', :action => 'index'
  map.list_formatted '/people/:user/lists/:id', :controller => 'lists', :action => 'list', :format => 'html'
  map.list '/people/:user/lists/:id.:format', :controller => 'lists', :action => 'list'
  map.observation '/people/:user/observations/:id', :controller => 'sighting', :action => 'view'
  map.observation_photo '/people/:user/observations/:sighting_id/photos/:id/:action', :controller => 'sighting_photo', :action => 'view'
  map.locations '/people/:user/locations', :controller => 'location', :action => 'index'
  map.location '/people/:user/locations/:id', :controller => 'location', :action => 'view'
  map.location_photo '/people/:user/locations/:location_id/photos/:id/:action', :controller => 'user_location_photo', :action => 'view'
  map.trips '/people/:user/trips', :controller => 'trip', :action => 'index'
  map.trip '/people/:user/trips/:id', :controller => 'trip', :action => 'view'
  map.trip_photo '/people/:user/trips/:trip_id/photos/:id/:action', :controller => 'trip_photo', :action => 'view'
  map.friends '/people/:user/friends', :controller => 'friends', :action => 'index'

  map.connect '/people/:login/:action', :controller => 'people', :action => 'view', :login => nil

  map.connect '/forums/', :controller => 'forums', :action => 'index'
  map.connect '/forums/:forum/:action/:id', :controller => 'forums', :action => 'forum', :id => nil

  # Special rule to rewrite requests to /main to just /  Yay for SEO
  map.connect 'main/:mainaction/:mainid', :controller => 'redirect', :action => 'main', :mainaction => nil, :mainid => nil

  # Bolt thinks people might type observation instead of sighting
  map.connect '/observation/:sightingaction/:sightingid', :controller => 'redirect', :action => 'sighting', :sightingaction => nil, :sightingid => nil

  map.solar '/solar-birding/:event/:page', :controller => 'solarbirding', :action => 'view', :event => 'index', :page => 'index'

  map.connect ':controller/:action/:id', :controller => 'main'
  map.help '/help/:action', :controller => 'help'
  map.tour '/tour/:action', :controller => 'tour'
  map.main '/:action/:id', :controller => 'main'
end
