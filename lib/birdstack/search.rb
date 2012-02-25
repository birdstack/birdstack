require 'csv'

module Birdstack
class Search
	ALLOWED_SEARCHES = {
		# The privacy clause on the user_locations is tricky.  It searches for NULL, 0, or 1.  1 is acceptable because
		# it means that only the lat/lon are private.  If we ever start doing searches based on lat/lon coords, a new
		# privacy clause will have to be created that accepts only NULL or 0--not 1.
		#
		# Things that deal specifically with the Sighting model do not need a privacy clause.  They are handled by a special
		# cause in generate_search_params.
		:observation_location_location => {
			:fields	=> [:location, :adm2, :adm1, :cc],
			:model	=> 'UserLocation',
			:joins	=> ['LEFT OUTER JOIN user_locations ON user_locations.id = sightings.user_location_id'],
			:privacy_clause => 'user_locations.private IS NULL OR user_locations.private = 0 OR user_locations.private = 1',
			:type	=> 'two_select',
		},
		:observation_location_adm2 => {
			:fields	=> [:adm2, :adm1, :cc],
			:model	=> 'UserLocation',
			:joins	=> ['LEFT OUTER JOIN user_locations ON user_locations.id = sightings.user_location_id'],
			:privacy_clause => 'user_locations.private IS NULL OR user_locations.private = 0 OR user_locations.private = 1',
			:type	=> 'two_select',
		},
		:observation_location_adm1 => {
			:fields	=> [:adm1, :cc],
			:model	=> 'UserLocation',
			:joins	=> ['LEFT OUTER JOIN user_locations ON user_locations.id = sightings.user_location_id'],
			:privacy_clause => 'user_locations.private IS NULL OR user_locations.private = 0 OR user_locations.private = 1',
			:type	=> 'two_select',
		},
		:observation_location_cc => {
			:fields	=> [:cc],
			:model	=> 'UserLocation',
			:joins	=> ['LEFT OUTER JOIN user_locations ON user_locations.id = sightings.user_location_id'],
			:privacy_clause => 'user_locations.private IS NULL OR user_locations.private = 0 OR user_locations.private = 1',
			:type	=> 'two_select',
		},
		:observation_location_name => {
			:fields	=> [:id],
			:model	=> 'UserLocation',
			:joins	=> ['LEFT OUTER JOIN user_locations ON user_locations.id = sightings.user_location_id'],
			:privacy_clause => 'user_locations.private IS NULL OR user_locations.private = 0 OR user_locations.private = 1',
			:type	=> 'two_select',
		},
		:observation_species => {
			:fields => [:id],
			:model	=> 'Species',
			:joins	=> ['LEFT OUTER JOIN species ON species.id = sightings.species_id'],
			:type	=> 'two_select',
		},
		:observation_tag => {
			:fields => [:id],
			:query_fields => {:id => nil},
			:model	=> 'Sighting',
			:joins	=> ['LEFT OUTER JOIN taggings ON sightings.id = taggings.taggable_id AND taggings.taggable_type = \'Sighting\' LEFT OUTER JOIN tags on taggings.tag_id = tags.id'],
			:type	=> 'two_select_tag',
		},
		:observation_ebird => {
			:fields 	=> [:ebird],
			:query_fields	=> {:ebird => nil},
			:model		=> 'Sighting',
			# Note that although the behavior for this type is defined below, the joins are defined here
			:joins		=> ['LEFT OUTER JOIN user_locations ON user_locations.id = sightings.user_location_id'],
			:type		=> 'ebird',
		},
		:observation_trip => {
			:fields	=> [:id],
			:model	=> 'Trip',
			:joins	=> ['LEFT OUTER JOIN trips ON trips.id = sightings.trip_id'],
			:privacy_clause => 'trips.private IS NULL OR trips.private = 0',
			:type	=> 'two_select',
		},
		:observation_order => {
			:fields => [:id],
			:model	=> 'Order',
			:joins	=> ['LEFT OUTER JOIN species ON species.id = sightings.species_id', 'LEFT OUTER JOIN genera ON genera.id = species.genus_id', 'LEFT OUTER JOIN families ON families.id = genera.family_id', 'LEFT OUTER JOIN orders ON orders.id = families.order_id'],
			:type	=> 'two_select',
		},
		:observation_family => {
			:fields => [:id],
			:model	=> 'Family',
			:joins	=> ['LEFT OUTER JOIN species ON species.id = sightings.species_id', 'LEFT OUTER JOIN genera ON genera.id = species.genus_id', 'LEFT OUTER JOIN families ON families.id = genera.family_id'],
			:type	=> 'two_select',
		},
		:observation_genus => {
			:fields => [:id],
			:model	=> 'Genus',
			:joins	=> ['LEFT OUTER JOIN species ON species.id = sightings.species_id', 'LEFT OUTER JOIN genera ON genera.id = species.genus_id'],
			:type	=> 'two_select',
		},
		:observation_ecoregion => {
			:fields 	=> [:id],
			:query_fields	=> {:id => :ecoregion},
			:model		=> 'UserLocation',
			:joins		=> ['LEFT OUTER JOIN user_locations ON user_locations.id = sightings.user_location_id'],
			:privacy_clause => 'user_locations.private IS NULL OR user_locations.private = 0 OR user_locations.private = 1',
			:type	=> 'two_select',
		},
		:observation_time => {
			:fields		=> [:hour_start, :minute_start, :hour_end, :minute_end],
			:query_fields	=> {:hour_start => :time_hour, :minute_start => :time_minute, :hour_end => :time_hour, :minute_end => :time_minute},
			:model		=> 'Sighting',
			:joins		=> [],
		},
		:observation_date => {
			:fields		=> [:date_day_start, :date_month_start, :date_year_start, :date_day_end, :date_month_end, :date_year_end],
			:query_fields	=> {:date_day_start => :date_day, :date_month_start => :date_month, :date_year_start => :date_year, :date_day_end => :date_day, :date_month_end => :date_month, :date_year_end => :date_year},
			:model		=> 'Sighting',
			:joins		=> [],
			:type		=> 'date'
		},
		:observation_elevation => {
			:fields		=> [:elevation_start, :elevation_end, :elevation_units],
			:model		=> 'UserLocation',
			:joins		=> ['LEFT OUTER JOIN user_locations ON user_locations.id = sightings.user_location_id'],
			:query_fields	=> {:elevation_units => nil, :elevation_start => :elevation_ft, :elevation_end => :elevation_ft},
			:privacy_clause => 'user_locations.private IS NULL OR user_locations.private = 0 OR user_locations.private = 1',
			:type		=> 'elevation'
		},
		:observation_search_type => {
			:fields		=> [:type],
			:model		=> 'Sighting',
			:joins		=> [],
			:query_fields	=> {:type => nil},
			:type		=> 'type'
		},
		:observation_search_display => {
			:fields		=> [:sort, :type],
			:model		=> 'Sighting',
			:joins		=> [],
			:query_fields	=> {:sort => nil, :type => nil},
			:type		=> 'display'
		}
	}

	SORT = {
		# eBird wants things by date and then location
		:ebird => {
			:joins	=> ['LEFT OUTER JOIN user_locations ON user_locations.id = sightings.user_location_id'],
			:clause	=> 'ISNULL(sightings.date_year), sightings.date_year, ISNULL(sightings.date_month), sightings.date_month, ISNULL(sightings.date_day), sightings.date_day, ISNULL(sightings.time_hour), sightings.time_hour, ISNULL(sightings.time_minute), sightings.time_minute, user_locations.id',
		},
		:date_asc => {
			:joins	=> [],
			:clause	=> 'ISNULL(sightings.date_year), sightings.date_year, ISNULL(sightings.date_month), sightings.date_month, ISNULL(sightings.date_day), sightings.date_day, ISNULL(sightings.time_hour), sightings.time_hour, ISNULL(sightings.time_minute), sightings.time_minute, sightings.created_at',
		},
		# Note: this code is duplicated in the Sighting model.  Should we somehow bring that in here?
		:date_desc => {
			:joins	=> [],
			:clause	=> 'ISNULL(sightings.date_year), sightings.date_year DESC, ISNULL(sightings.date_month), sightings.date_month DESC, ISNULL(sightings.date_day), sightings.date_day DESC, ISNULL(sightings.time_hour), sightings.time_hour DESC, ISNULL(sightings.time_minute), sightings.time_minute DESC, sightings.created_at DESC',
		},
		:species_english_asc => {
			:joins	=> ['LEFT OUTER JOIN species ON species.id = sightings.species_id'],
			:clause	=> 'species.english_name ASC',
		},
		:species_english_desc => {
			:joins	=> ['LEFT OUTER JOIN species ON species.id = sightings.species_id'],
			:clause	=> 'species.english_name DESC',
		},
		:scientific_desc => {
			:joins	=> ['LEFT OUTER JOIN species ON species.id = sightings.species_id', 'LEFT OUTER JOIN genera ON genera.id = species.genus_id'],
			:clause	=> 'genera.latin_name DESC, species.latin_name DESC',
		},
		:scientific_asc => {
			:joins	=> ['LEFT OUTER JOIN species ON species.id = sightings.species_id', 'LEFT OUTER JOIN genera ON genera.id = species.genus_id'],
			:clause	=> 'genera.latin_name ASC, species.latin_name ASC',
		},
		:species_taxonomic => {
			:joins	=> ['LEFT OUTER JOIN species ON species.id = sightings.species_id'],
			:clause	=> 'species.sort_order ASC',
		},
		:created_at_desc => {
			:joins => [],
			:clause => 'sightings.created_at DESC',
		},
	}


	attr_accessor :hash

	def Search.sanitize_hash(bad_hash)
		good_hash = {}

		ALLOWED_SEARCHES.each_key do |search_type|
			if !bad_hash[search_type].blank? then
				fields = nil

				if ALLOWED_SEARCHES[search_type][:type].andand.starts_with? 'two_select' then
					fields = bad_hash[search_type][:id].to_a.collect {|i| self.sanitize_fields(self.csv_to_hash(i, search_type), search_type) }
				else
					fields = self.sanitize_fields(bad_hash[search_type], search_type)
				end

				# This way, we only create the key if there's actually stuff to put in it
				if !fields.blank? then
					good_hash[search_type] = fields
				end
			end
		end

		good_hash
	end
	
	def Search.sanitize_fields(current_hash, search_type)
		fields = {}

		ALLOWED_SEARCHES[search_type][:fields].each do |field|
			if !current_hash[field].blank? then
				cast_field = Search.translate_query_field(search_type, field)

				# Now we typecast it just as if it were really in that object
				# Note that this does not respect serialized fields
				# We couldn't really search on serialization anyway
				# If the cast_field is nil, we don't do casting
				unless cast_field.nil? then
					fields[field] = Kernel.const_get(ALLOWED_SEARCHES[search_type][:model]).columns_hash[cast_field.to_s].type_cast(current_hash[field])
				else
					fields[field] = current_hash[field]
				end
			end
		end

		return fields
	end

	def initialize(search_owner, hash, serialized, current_user)
		@search_owner = search_owner
		@current_user = current_user

		unless serialized then
			@hash = Search.sanitize_hash(hash)
		else
			@hash = YAML::load(hash)
		end

		@search_params = nil
	end

	def merge_additional_params(hash)
		@hash = @hash.merge(Search.sanitize_hash(hash))
	end

	# TODO this was an unfortunate API choice.  .freeze is a standard Ruby thing that locks the object.  Should be changed
	def freeze
		generate_search_params
		throw "Cannot freeze invalid search" unless errors.empty?
		@hash.to_yaml
	end

	def generate_instance_vars(obj)
		@hash.each_key do |search_type|
			val = nil

			if ALLOWED_SEARCHES[search_type][:type].andand.starts_with? 'two_select' then
				val = @hash[search_type].collect {|i| Search.hash_to_csv(i, search_type) }
			else
				val = Struct.new(*ALLOWED_SEARCHES[search_type][:fields]).new(*ALLOWED_SEARCHES[search_type][:fields].collect {|i| @hash[search_type][i] })
			end

			obj.instance_variable_set(('@' + search_type.to_s).to_sym, val)
		end
	end

	def Search.obj_to_csv(obj, type)
		line = []
		hash = Search.obj_to_hash(obj, type)
		ALLOWED_SEARCHES[type.to_sym][:fields].each { |e| line << hash[e] }
		CSV.generate_line(line)
	end

	def Search.obj_to_hash(obj, type)
		type = type.to_sym
		hash = {}
		ALLOWED_SEARCHES[type][:fields].each { |e| hash[e] = obj.send(e) }

		return self.sanitize_fields(hash, type)
	end

	def Search.hash_to_csv(hash, type)
		line = []
		ALLOWED_SEARCHES[type.to_sym][:fields].each { |e| line << hash[e] }
		CSV.generate_line(line)
	end

	def Search.csv_to_hash(csv, type)
		line = CSV.parse_line(csv.to_s).collect {|i| i.to_s } # Have to do to_s otherwise the class of each cell is CSV::Cell, which is bad for YAML
		hash = {}
		ALLOWED_SEARCHES[type.to_sym][:fields].each { |e| hash[e] = line.shift }
		
		return hash
	end

	def run_validations
		errors.clear
		errors[:search] = 'Search contains no valid terms' unless @hash.size > 0

		date = @hash[:observation_date]
		if !date.blank? then
			if !date[:date_day_start].blank? then
				errors[:observation_date] = 'Starting year required with day' unless !date[:date_year_start].blank?
				errors[:observation_date] = 'Starting month required with day' unless !date[:date_month_start].blank?
			elsif !date[:date_month_start].blank? then
				errors[:observation_date] = 'Starting year required with month' unless !date[:date_year_start].blank?
			end

			if [:date_day_start, :date_month_start, :date_year_start].detect {|f| !date[f].blank? } then
				unless Date.valid_civil?(date[:date_year_start] || Date.today.year, date[:date_month_start] || 1, date[:date_day_start] || 1) then
					errors[:observation_date] = 'Starting date is invalid'
				end
			end

			if !date[:date_day_end].blank? then
				errors[:observation_date] = 'Ending year required with day' unless !date[:date_year_end].blank?
				errors[:observation_date] = 'Ending month required with day' unless !date[:date_month_end].blank?
			elsif !date[:date_month_end].blank? then
				errors[:observation_date] = 'Ending year required with month' unless !date[:date_year_end].blank?
			end

			if [:date_day_end, :date_month_end, :date_year_end].detect {|f| !date[f].blank? } then
				unless Date.valid_civil?(date[:date_year_end] || Date.today.year, date[:date_month_end] || 1, date[:date_day_end] || 1) then
					errors[:observation_date] = 'Ending date is invalid'
				end
			end

			# TODO It would be nice to validate that the range isn't backwards, but this is complicated because we allow
			# partial dates.  For example, how to validate that March 3, 1985 through 1985 is valid.
		end

		elevation = @hash[:observation_elevation]
		if !elevation.blank? then
			if !elevation[:elevation_start].blank? and !elevation[:elevation_end].blank? then
				if elevation[:elevation_end] < elevation[:elevation_start] then
					errors[:observation_elevation] = 'Maximum elevation (the "below" value) must be higher than minimum elevation (the "above" value)'
				end
			end

			if !elevation[:elevation_start].blank? or !elevation[:elevation_end].blank? then
				if elevation[:elevation_units].blank? then
					errors[:observation_elevation] = 'Elevation units must be selected'
				end
			end
		end

		return errors.empty?
	end

        # Sorta emulate ActiveRecord::Errors.  Yeesh, this module needs a rewrite
	def errors
		@errors ||= {}
	end

	def search_params
		generate_search_params unless @search_params
		@search_params
	end

	def search_no_paginate(sort = nil, limit = nil)
		search(nil, nil, sort, false, limit)
	end

	def search(page = nil, per_page = nil, sort = nil, paginate = true, limit = nil)
		return unless self.search_params

		params = self.search_params

		# Default to date_desc sorting
		sort ||= @hash[:observation_search_display][:sort] if @hash[:observation_search_display]
		unless sort and SORT[sort.to_sym] then
			sort = :date_desc
		end
		sort = SORT[sort.to_sym]

		# Default to 100 results per page, or 25 if report style
		unless per_page.to_i > 0 then
			if @hash[:observation_search_display] and @hash[:observation_search_display][:type] == 'report' then
				per_page = 25
			else
				per_page = 100
			end
		end

		sightings = []

		sql_query = {}

		if @type and (@type == 'earliest' or @type == 'latest') then
			# We have to do this scary thing
			# Create a temporary table with the search results (ordered by date, giving user dates preference) numbered with a counter
			# Use a GROUP BY query to find the max counter value for each species
			# Use another query to find the actual sightings entry by the counter ids returned
			
			conn = Sighting.connection

			conn.execute('DROP TEMPORARY TABLE IF EXISTS first_sightings')
			conn.execute('set @counter := 0')

			if @type == 'earliest' then
				conn.execute(ActiveRecord::Base.send(:sanitize_sql_array,
					['CREATE TEMPORARY TABLE first_sightings (PRIMARY KEY (counter)) SELECT @counter := @counter + 1 as counter, sightings.* FROM sightings ' +
					params[:joins].uniq.join(' ') +
					' WHERE ' + params[:conditions][0] +
					' ORDER BY ' + SORT[:date_asc][:clause],
					*params[:conditions][1..-1]]))
			elsif @type == 'latest' then
				conn.execute(ActiveRecord::Base.send(:sanitize_sql_array,
					['CREATE TEMPORARY TABLE first_sightings (PRIMARY KEY (counter)) SELECT @counter := @counter + 1 as counter, sightings.* FROM sightings ' +
					params[:joins].uniq.join(' ') +
					' WHERE ' + params[:conditions][0] +
					' ORDER BY ' + SORT[:date_desc][:clause],
					*params[:conditions][1..-1]]))
			else
				throw 'Unknown search type ' + @type
			end

			counter_ids = conn.select_all('SELECT MIN(counter) FROM first_sightings GROUP BY species_id').collect {|i| i.values[0]}
			# We have to calculate the total entries ourselves because will_paginate can't deal with our custom sql query
			total_entries = conn.select_value(ActiveRecord::Base.send(:sanitize_sql_array, ['SELECT COUNT(*) FROM first_sightings WHERE counter IN (?)', counter_ids]))

			sort_joins = sort[:joins].uniq.join(' ')
			sort_clause = sort[:clause]

			# It's important that we select only sightings.* or else ActiveRecord will get confused if we join in other tables
			# Also important is the aliasing of first_sightings to sightings so that our joins work with both this version and also the regular one below
			if paginate then
				sightings = Sighting.paginate_by_sql(['SELECT sightings.* FROM first_sightings AS sightings ' + sort_joins + ' WHERE counter IN (?) ORDER BY ' + sort_clause, counter_ids], :page => page, :per_page => per_page, :total_entries => total_entries)
			else
				sightings = Sighting.find_by_sql(['SELECT sightings.* FROM first_sightings AS sightings ' + sort_joins + ' WHERE counter IN (?) ORDER BY ' + sort_clause + (limit ? ' LIMIT ' + limit.to_i.to_s : ''), counter_ids])
			end
		else
			# Here, we have to add a second pass to weed out duplicate results.
			# For example, a tag could match twice.  If a sighting is tagged with both 'cheese' and 'llama',
			# and the user searches for sightings that match either 'cheese' or 'llama', that particular sighting
			# will be returned twice because we're doing a JOIN.
			# Sure, we could optimize it so that the extra pass happens only for tag searches, but I've got a
			# feeling that we'll be adding more of these kinds of searches in the future, and this prevents
			# badness from occurring unexpectedly down the road.
			# Also note that this second pass is not needed for the 'earliest' or 'latest' style searches above.
			# They've already got a second pass built in.

			# The param JOINs must go in the subselect or else we'll still get duplicates
			# However, the ORDER BY joins must go in the regular select or else the tables needed to sort won't exist
			# If we ever decide to start ordering by tags or any other field that causes duplicate results, we're sunk
			param_join_string = params[:joins].uniq.join(' ')
			order_by_join_string = sort[:joins].uniq.join(' ')
			params[:conditions][0] = "sightings.id IN (SELECT DISTINCT sightings.id FROM sightings #{param_join_string} WHERE #{params[:conditions][0]})"

			if paginate then
				sightings = Sighting.paginate(:conditions => params[:conditions], :order => sort[:clause], :joins => order_by_join_string, :page => page, :per_page => per_page)
			else
				sightings = Sighting.find(:all, :conditions => params[:conditions], :order => sort[:clause], :joins => order_by_join_string, :limit => limit)
			end
		end

		if @current_user != @search_owner then
			sightings.each {|sighting| sighting = sighting.publicize!(@current_user) }
		end

		return sightings
	end

	def generate_search_params
		@search_params = nil
		return unless run_validations

		sql_conditions = []
		sql_params = []
		sql_joins = []

		ALLOWED_SEARCHES.each_key do |search_type|
			next unless !@hash[search_type].blank?
			table = ALLOWED_SEARCHES[search_type][:model].tableize

			add_to_sql_conditions = []

			if ALLOWED_SEARCHES[search_type][:type] == 'elevation' then
				field = 'elevation_ft'
				if @hash[search_type][:elevation_units] == 'm' then
					field = 'elevation_m'
				end

				sql_and_conditions = []

				if !@hash[search_type][:elevation_start].blank? then
					sql_and_conditions << table + '.' + field + ' >= ?'
					sql_params << @hash[search_type][:elevation_start]
				end

				if !@hash[search_type][:elevation_end].blank? then
					sql_and_conditions << table + '.' + field + ' <= ?'
					sql_params << @hash[search_type][:elevation_end]
				end

				add_to_sql_conditions << '(' + sql_and_conditions.join(' AND ') + ')' if sql_and_conditions.size > 0
			elsif ALLOWED_SEARCHES[search_type][:type] == 'display' then
				# We do nothing.  It doesn't affect the query at this point.
			elsif ALLOWED_SEARCHES[search_type][:type] == 'ebird' then
				# Note that joins are defined in the ALLOWED_SEARCHES block above
				# Include: date, matching cc, coordinates (user-entered, ppl, or click)
				add_to_sql_conditions << '(' +
					'sightings.ebird IS NULL AND ' +
					'sightings.ebird_exclude = 0 AND ' +
					'sightings.date_day IS NOT NULL AND sightings.date_month IS NOT NULL and sightings.date_year IS NOT NULL AND ' +
					'user_locations.cc IN (?) AND ' +
					'user_locations.latitude IS NOT NULL AND user_locations.longitude IS NOT NULL AND ' +
					'(user_locations.source IN (?) OR (user_locations.source = ? AND user_locations.zoom >= ?))' +
					')'
				sql_params << EBIRD_MAP.keys
				sql_params << ['ppl', 'user']
				sql_params << 'gmap'
				sql_params << EBIRD_USER_ZOOM_MIN
			elsif ALLOWED_SEARCHES[search_type][:type] == 'type' then
				if !@hash[search_type][:type].blank? then
					@type = @hash[search_type][:type]
				end
			elsif ALLOWED_SEARCHES[search_type][:type] == 'two_select_tag' then
				tags = @hash[search_type].collect {|i| i[:id] }
				add_to_sql_conditions << '(' + (['tags.name LIKE ?'] * tags.size).join(' OR ') + ')'
				sql_params += tags
			elsif ALLOWED_SEARCHES[search_type][:type] == 'date' then
				fieldset = @hash[search_type]

				# We'll use these a lot, build them up now (while respecting config instead of hardcoding)
				qfs = Hash.new
				ALLOWED_SEARCHES[search_type][:fields].each do |field|
					qfs[field] = Search.translate_query_field(search_type, field).to_s
				end

				sql_or_conditions = []
				
				# Thanks to validation, we're guaranteed hierarchical data.  That is, if we have a day, we must have month and year.
				if fieldset[:date_day_start] then
					sql_or_conditions << '(' + table + '.' + qfs[:date_day_start] + ' >= ? AND ' + table + '.' + qfs[:date_month_start] + ' = ? AND ' + table + '.' + qfs[:date_year_start] + ' = ?)'
					sql_params += [fieldset[:date_day_start], fieldset[:date_month_start], fieldset[:date_year_start]]

					sql_or_conditions << '(' + table + '.' + qfs[:date_month_start] + ' > ? AND ' + table + '.' + qfs[:date_year_start] + ' = ?)'
					sql_params += [fieldset[:date_month_start], fieldset[:date_year_start]]

					sql_or_conditions << table + '.' + qfs[:date_year_start] + ' > ?'
					sql_params += [fieldset[:date_year_start]]
				elsif fieldset[:date_month_start] then
					sql_or_conditions << '(' + table + '.' + qfs[:date_month_start] + ' >= ? AND ' + table + '.' + qfs[:date_year_start] + ' = ?)'
					sql_params += [fieldset[:date_month_start], fieldset[:date_year_start]]

					sql_or_conditions << table + '.' + qfs[:date_year_start] + ' > ?'
					sql_params += [fieldset[:date_year_start]]
				elsif fieldset[:date_year_start] then
					sql_or_conditions << table + '.' + qfs[:date_year_start] + ' >= ?'
					sql_params += [fieldset[:date_year_start]]
				end

				add_to_sql_conditions << '(' + sql_or_conditions.join(' OR ') + ')' if sql_or_conditions.size > 0

				# And now the 'end' side of things

				sql_or_conditions = []
				
				if fieldset[:date_day_end] then
					sql_or_conditions << '(' + table + '.' + qfs[:date_day_end] + ' <= ? AND ' + table + '.' + qfs[:date_month_end] + ' = ? AND ' + table + '.' + qfs[:date_year_end] + ' = ?)'
					sql_params += [fieldset[:date_day_end], fieldset[:date_month_end], fieldset[:date_year_end]]

					sql_or_conditions << '(' + table + '.' + qfs[:date_month_end] + ' < ? AND ' + table + '.' + qfs[:date_year_end] + ' = ?)'
					sql_params += [fieldset[:date_month_end], fieldset[:date_year_end]]

					sql_or_conditions << table + '.' + qfs[:date_year_end] + ' < ?'
					sql_params += [fieldset[:date_year_end]]
				elsif fieldset[:date_month_end] then
					sql_or_conditions << '(' + table + '.' + qfs[:date_month_end] + ' <= ? AND ' + table + '.' + qfs[:date_year_end] + ' = ?)'
					sql_params += [fieldset[:date_month_end], fieldset[:date_year_end]]

					sql_or_conditions << table + '.' + qfs[:date_year_end] + ' < ?'
					sql_params += [fieldset[:date_year_end]]
				elsif fieldset[:date_year_end] then
					sql_or_conditions << table + '.' + qfs[:date_year_end] + ' <= ?'
					sql_params += [fieldset[:date_year_end]]
				end

				add_to_sql_conditions << '(' + sql_or_conditions.join(' OR ') + ')' if sql_or_conditions.size > 0
			else
				sql_or_conditions = []
				# The flatten thing is just a trick to make sure we're dealing with an array.
				# If it's a single item, it encases it inside an array.
				# If it's an array, we get a nested array, which is then flattened
				# Funny looking, but it works
				[@hash[search_type]].flatten.each do |fieldset|
					sql_and_conditions = []

					ALLOWED_SEARCHES[search_type][:fields].each do |field|
						query_field = Search.translate_query_field(search_type, field)

						# If the string is empty, we might want to be searching for a NULL in the db
						# or maybe an empty string.  So, in that case, we'll just search for both!
						if fieldset[field].blank? then
							sql_and_conditions << '(' + table + '.' + query_field.to_s + ' IS NULL OR ' + table + '.' + query_field.to_s + ' = "")'
						else
							sql_and_conditions << table + '.' + query_field.to_s + ' = ?'
							sql_params << fieldset[field]
						end
					end

					sql_or_conditions << '(' + sql_and_conditions.join(' AND ') + ')'
				end

				add_to_sql_conditions << '(' + sql_or_conditions.join(' OR ') + ')' if sql_or_conditions.size > 0
			end

			# Add a privacy clause if needed
			# This makes sure that not only does the search return only public observations, it also will not find
			# observations using information that is not public
			if is_public? and !ALLOWED_SEARCHES[search_type][:privacy_clause].blank? then
				add_to_sql_conditions = ['((' + add_to_sql_conditions.join(' AND ') + ') AND (' + ALLOWED_SEARCHES[search_type][:privacy_clause] + '))']
			end

			sql_conditions += add_to_sql_conditions
			sql_joins += ALLOWED_SEARCHES[search_type][:joins]
		end

		if @search_owner then
			sql_conditions << 'sightings.user_id = ?'
			sql_params << @search_owner.id
		end

		if is_public? then
			sql_conditions << '(sightings.private = 0 OR sightings.private IS NULL)'
		end

		# Note that we do a .uniq on the joins to remove duplicate ones
		@search_params = {:conditions => [sql_conditions.join(' AND ')] + sql_params, :joins => sql_joins}

		return errors.empty?
	end

	def is_public?
		return @search_owner != @current_user
	end

	def Search.translate_query_field(search_type, field)
		query_field = field
		if ALLOWED_SEARCHES[search_type][:query_fields] and ALLOWED_SEARCHES[search_type][:query_fields].include?(field) then
			query_field = ALLOWED_SEARCHES[search_type][:query_fields][field]
		end

		return query_field
	end
end
end
