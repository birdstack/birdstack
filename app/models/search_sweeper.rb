require 'find'

class SearchSweeper < ActionController::Caching::Sweeper
	observe SavedSearch, UserLocation, Trip, Sighting, User, AlternateName

	def after_save(record)
                remember_record(record)

		# Don't bother if this is a part of a batch operation
		unless (record.respond_to?(:batch) and record.batch) then
			expire_search_fragments
		end
	end

	def after_destroy(record)
                remember_record(record)

		# Don't bother if this is a part of a batch operation
		unless (record.respond_to?(:batch) and record.batch) then
                  expire_search_fragments
                end
	end

	private

        # See note in SightingSweeper for an explanation of how/why this works
        def remember_record(record)
          # If it's a saved search, it affects only that search
          # If it's any other kind of record, then it could potentially affect everything for that user
          
          if record.is_a?(SavedSearch) then
            key = (self.class.to_s + 'saved_searches').to_sym
            Thread.current[key] ||= Set.new
            Thread.current[key] << record
          elsif record.is_a?(User) then
            key = (self.class.to_s + 'render_for_ids').to_sym
            Thread.current[key] ||= Set.new
            Thread.current[key] << record.id
          elsif record.is_a?(AlternateName) then
            key = (self.class.to_s + 'alternate_names').to_sym
            Thread.current[key] ||= Set.new
            Thread.current[key] << record
          else
            key = (self.class.to_s + 'users').to_sym
            Thread.current[key] ||= Set.new
            Thread.current[key] << record.user
          end
        end

	def expire_search_fragments
          Species.benchmark "expire_search_fragments", Logger::INFO do
                # Allows this sweeper to work outside of a controller (script/runner, etc)
                if(@controller.nil?) then
                  @controller = ApplicationController.new
                end

                key = (self.class.to_s + 'saved_searches').to_sym
                if(Thread.current[key] and Thread.current[key].size > 0) then
                  saved_search_match = Thread.current[key].collect {|s| s.id }.join('|')
                  expire_fragment(%r{observations_pagination/list_observations/(#{saved_search_match})})

                  # Make sure caching is turned on
                  if(page_cache_directory) then
                    Thread.current[key].each do |s|
                      Find.find(page_cache_directory + "/people/#{s.user.login}/lists") do |path|
                        if(File.basename(path) =~ /^#{s.id}/) then
                          logger.info("Expiring for search id #{s.id}: #{path}")
                          begin
                            FileUtils.remove_entry_secure(path)
                          rescue Errno::ENOENT
                            # If the file's no there, that's fine
                          end
                          Find.prune
                        end
                      end
                    end
                  end

                  Thread.current[key] = Set.new
                end

                key = (self.class.to_s + 'render_for_ids').to_sym
                if(Thread.current[key] and Thread.current[key].size > 0) then
                  render_for_match = Thread.current[key].to_a.join('|')
                  expire_fragment(%r{observations_pagination/[^/]+/.*render_for=(#{render_for_match})})
                  Thread.current[key] = Set.new
                end

                key = (self.class.to_s + 'users').to_sym
                if(Thread.current[key] and Thread.current[key].size > 0) then
                  # Expire paginations containing data from this user
                  users_match = Thread.current[key].collect {|u| u.id }.join('|')
                  expire_fragment(%r{observations_pagination/[^/]+/.*user=(#{users_match})})

                  # Make sure caching is turned on
                  if(page_cache_directory) then
                    # Expire stacks (js, atom) containing data from this user
                    Thread.current[key].each do |u|
                      expire_path = page_cache_directory + "/people/#{u.login}/lists"
                      next unless File.directory?(expire_path)
                      logger.info("Expiring for user #{u.login}: #{expire_path}")
                      FileUtils.remove_entry_secure(expire_path)
                    end
                  end
                  
                  Thread.current[key] = Set.new
                end

                key = (self.class.to_s + 'alternate_names').to_sym
                if(Thread.current[key] and Thread.current[key].size > 0) then
                  # Make sure caching is turned on
                  if(page_cache_directory) then
                    # If there are any AlternateName changes, we have to expire the entire auto_complete cache
                    # Potential optimization: be clever about expiring only things that could potentially match
                    # the (new or old) alternate name.  Right now, I'm going to say that's too easy to get wrong
                    # and the payoff is too small to care.
                    expire_path = page_cache_directory + "/sighting/"
                    if File.directory?(expire_path) then
                      logger.info("Expiring for alternate name change: #{expire_path}")
                      # If we ever start caching anything else in this dir, we'll have to be more selective
                      FileUtils.remove_entry_secure(expire_path)
                    end
                  end
                end
          end
	end
end
