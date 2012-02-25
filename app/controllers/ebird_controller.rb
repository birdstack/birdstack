class EbirdController < ApplicationController
	def generate
		@saved_search = current_user.saved_searches.find_by_id(params[:id])
		
		unless @saved_search then
			redirect_to :action => 'index'
			return
		end

		search = Birdstack::Search.new(@saved_search.user, @saved_search.search, true, current_user)
		search.merge_additional_params({
			:observation_ebird => {:ebird => true}
		})

		Sighting.transaction do
			@results = search.search_no_paginate('ebird')

			rows = []
			sightings_exported = []
			@results.each do |sighting|
				(ebird_cc, ebird_adm1) = EBIRD_MAP[sighting.user_location.cc].andand[sighting.user_location.adm1] || EBIRD_MAP[sighting.user_location.cc]['']

				# eBird does not currently accept ADM1s that are <2 chars
				if ebird_adm1.length < 2 then
					ebird_adm1 = ''
				end

				rows << CSV.generate_line([
					sighting.species.english_name,
					sighting.species.genus.latin_name,
					sighting.species.latin_name,
					sighting.species_count,
					sighting.notes,
					sighting.user_location.name,
					sighting.user_location.latitude,
					sighting.user_location.longitude,
					sighting.date_month.to_s + '/' + sighting.date_day.to_s + '/' + sighting.date_year.to_s,
					(sighting.trip and sighting.trip.time_hour_start) ? sighting.trip.time_hour_start.to_s + ':' + sprintf("%02d", sighting.trip.time_minute_start) : '',
					ebird_adm1,
					ebird_cc,
					sighting.trip ? sighting.trip.protocol : 'casual',
					sighting.trip ? sighting.trip.number_observers : '',
					(sighting.trip and sighting.trip.duration_hours) ? sighting.trip.duration_hours * 60 + sighting.trip.duration_minutes : '', # duration
					(sighting.trip and sighting.trip.all_observations_reported) ? 'Y' : 'N', # all observations reported
					sighting.trip ? sighting.trip.distance_traveled_mi : '', # distance covered
					sighting.trip ? sighting.trip.area_covered_acres : '', # area covered
					sighting.trip ? sighting.trip.description : '' # checklist (trip) comments
				].collect do |field|
						# eBird can't handle quotes, CRs, or LFs in the CSV
						field = field.to_s.gsub(/"|\r|\n/,'')
						# eBird expects iso-9959-1 (or maybe not?!), and we try to do everything in UTF8.
						# Try to convert.  If it fails, too bad.
						# If people have non-UTF8 in their comments, that's a likely reason to fail
                                                backup_field = field # in case Iconv failes
						begin
							field = Iconv.conv('iso-8859-1', 'UTF8', field)
						rescue Exception
                                                        field = backup_field
							# At least we tried
						end
					end
				)
				sightings_exported << sighting.id
			end

			if sightings_exported.size > 0 then
				@export = EbirdExport.new()
				@export.user = current_user
				@export.description = params[:ebird_export].andand[:description] || 'Untitled'
				@export.content_type = 'text/plain'
				@export.filename = "ebird_#{@saved_search.id}_#{Time.now.strftime('%Y-%m-%d_%H-%M')}.csv"
				@export.temp_data = rows.join("\n")
				@export.save!

				Sighting.update_all(['ebird = ?', @export.id], ['sightings.user_id = ? AND sightings.id IN (?)', current_user.id, sightings_exported])
			end
		end
	end

	def index
		@exports = current_user.ebird_exports
	end

	def download
		export = current_user.ebird_exports.find_by_id(params[:id])
		
		unless export then
			redirect_to :action => 'index'
			return
		end

		send_data(export.temp_data, :type => export.content_type, :filename => export.filename)
	end
end
