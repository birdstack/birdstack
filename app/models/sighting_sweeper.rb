class SightingSweeper < ActionController::Caching::Sweeper
	observe Sighting

	def after_save(record)
                remember_record(record)

		# Don't expire things if this is a part of a large batch operation
		unless record.batch
			expire_sighting_fragments
		end
	end

	def after_destroy(record)
                remember_record(record)

		# Don't expire things if this is a part of a large batch operation
		unless record.batch
                  expire_sighting_fragments
                end
	end

	private

        # Use Thread.current so we can store up a list of affected species ids for the current request
        # The idea is that for a batch operation, the controller saves a bunch of sightings with .batch set to true.
        # Thread.current then builds up the list of species ids that need to have cache items cleared.
        # Then, at the end of the cycle, the controller saves a sighting (doesn't matter which one) with
        # .batch set to false.  Then, we iterate through the cached items only once, clearing out what needs
        # to be cleared.  This is much more efficient than calling expire_fragment with a regex for every
        # saved sighting.
        def remember_record(record)
          key = (self.class.to_s + 'species_ids').to_sym
          Thread.current[key] ||= Set.new
          Thread.current[key] << record.species_id
        end

	# Note that this sweeper is for things that are affected only by sightings.
	# Everything else is covered in SearchSweeper
	def expire_sighting_fragments
          Species.benchmark "expire_sighting_fragments", Logger::INFO do
                # Allows this sweeper to work outside of a controller (script/runner, etc)
                if(@controller.nil?) then
                  @controller = ApplicationController.new
                end

                key = (self.class.to_s + 'species_ids').to_sym

		species_match = Thread.current[key].to_a.join('|')

		expire_fragment('sidebar_stack')
		expire_fragment(%r{observations_pagination/species_map/(#{species_match})})

                Thread.current[key] = Set.new
          end
	end
end
