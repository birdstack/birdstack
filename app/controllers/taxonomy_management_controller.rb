class TaxonomyManagementController < ApplicationController
	def index
		@changes = current_user.find_pending_taxonomy_changes
	end

	def lump
		@change = Change.find(:first, :conditions => {:id => params[:id], :change_type => 'lump'})

		unless @change then
			redirect_to :controller => 'taxonomy_management', :action => 'index'
			return
		end

		params[:notes] ||= "(#{Time::now().strftime('%Y/%m/%d')}) Taxonomy upgrade: Converted from #{@change.species.english_name}"

		return unless request.post?
		
		new_species = @change.potential_species[0] # There's only 1 potential species with a lump

		# All or nothing.  Seems reasonable
		Sighting.transaction do
			current_user.sightings.find(:all, :conditions => {:species_id => @change.species.id}).each do |sighting|
				sighting.notes = sighting.notes.to_s + "\n\n" + params[:notes]
				sighting.species = new_species
				sighting.batch = true
				sighting.save!
			end
			# Save a sighting so that cache updates happen (didn't happen before because we set batch to true)
			current_user.sightings.find(:first).save!
		end

		redirect_to :controller => 'taxonomy_management', :action => 'index'
	end

	def split
		@change = Change.find(:first, :conditions => {:id => params[:id], :change_type => 'split'})

		unless @change then
			redirect_to :controller => 'taxonomy_management', :action => 'index'
			return
		end

		search = Birdstack::Search.new(current_user, {:observation_species => {:id => [@change.species.id]}}, false, current_user) 
		@sightings = search.search_no_paginate(:date_asc, 50)

		unless @sightings.size > 0 then
			redirect_to :controller => 'taxonomy_management', :action => 'index'
			return
		end

		params[:notes] ||= "(#{Time::now().strftime('%Y/%m/%d')}) Taxonomy upgrade: Converted from #{@change.species.english_name}"

		return unless request.post?

                begin
                  Sighting.transaction do
                          params[:sightings].each do |sighting_id, new_species_id|
                                  new_species = Species.find_valid_by_id(new_species_id)
                                  next unless new_species
                                  debugger
                                  sighting = current_user.sightings.find(sighting_id)
                                  sighting.notes = sighting.notes.to_s + "\n\n" + params[:notes]
                                  sighting.species = new_species
                                  sighting.batch = true
                                  sighting.save!
                          end
                          # Save a sighting so that cache updates happen (didn't happen before because we set batch to true)
                          current_user.sightings.find(:first).save!
                  end
                rescue ActiveRecord::StaleObjectError
                  if @rescued_stale_object then
                    raise
                  else
                    logger.warn("Rescuing StaleObjectError for TaxonomyManagementController#split")
                    @rescued_stale_object = true
                    retry
                  end
                end

		# Search again for sightings that need to be changed
		@sightings = search.search_no_paginate(:date_asc, 50)

		# Redir to the main taxonomy_management index if nothing needs to be changed
		unless @sightings.size > 0 then
			redirect_to :controller => 'taxonomy_management', :action => 'index'
			return
		end
	end

	def removal
		@change = Change.find(:first, :conditions => {:id => params[:id], :change_type => 'removal'})

		unless @change then
			redirect_to :controller => 'taxonomy_management', :action => 'index'
			return
		end

		search = Birdstack::Search.new(current_user, {:observation_species => {:id => [@change.species.id]}}, false, current_user) 
		@sightings = search.search_no_paginate(:date_asc, 50)

		unless @sightings.size > 0 then
			redirect_to :controller => 'taxonomy_management', :action => 'index'
			return
		end

		return unless request.post?

		Sighting.transaction do
			params[:sightings].each do |sighting_id, action|
				next unless action == 'delete'
				sighting = current_user.sightings.find(sighting_id)
				sighting.batch = true
				sighting.destroy
			end
			# Save a sighting so that cache updates happen (didn't happen before because we set batch to true)
			current_user.sightings.find(:first).andand.save!
		end


		# Search again for sightings that need to be changed
		@sightings = search.search_no_paginate(:date_asc, 50)

		# Redir to the main taxonomy_management index if nothing needs to be changed
		unless @sightings.size > 0 then
			redirect_to :controller => 'taxonomy_management', :action => 'index'
			return
		end
	end
end
