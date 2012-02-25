require ARGV[0]

class DummyController
	def logger
		RAILS_DEFAULT_LOGGER
	end
	def headers
		{}
	end
end

action_view = ActionView::Base.new(Rails::Configuration.new.view_path, {}, DummyController.new) 

puts action_view.render(:file => ARGV[1], :locals => {:species_updates => @@species_updates, :species_splits => @@species_splits, :species_deletes => @@species_deletes, :family_updates => @@family_updates, :species_new => @@species_new, :family_new => @@family_new, :genus_updates => @@genus_updates})

