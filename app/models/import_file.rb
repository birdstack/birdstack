require 'csv'

class ImportFile < Tableless
	# Make sure the keys are all lower case
	# Values should be prefixed with _ if they are virtual
	# Make sure new regex's will take blank rows as valid
	COLUMNS = {
		'english name'		=> ['english_name', /.+/],
		'location name'		=> ['location_name', /.*/],
		'year'			=> ['date_year', /\A([0-9]+)?\z/],
		'month'			=> ['date_month', /\A([0-9]+)?\z/],
		'day'			=> ['date_day', /\A([0-9]+)?\z/],
		'mdy date'		=> ['_mdy_date'],
		'dmy date'		=> ['_dmy_date'],
		'iso date'		=> ['_iso_date'],
		'trip name'		=> ['trip_name', /.*/],
		'12-hour time'		=> ['_12hr_time'],
		'24-hour time'		=> ['_24hr_time'],
		'24-hour hour'		=> ['time_hour', /\A([0-9]+)?\z/],
		'minute'		=> ['time_minute', /\A([0-9]+)?\z/],
		'number observed'	=> ['species_count'],
		'juvenile_male'		=> ['juvenile_male', /\A([0-9]+)?\z/],
		'juvenile_female'	=> ['juvenile_female', /\A([0-9]+)?\z/],
		'juvenile_unknown'	=> ['juvenile_unknown', /\A([0-9]+)?\z/],
		'immature_male'		=> ['immature_male', /\A([0-9]+)?\z/],
		'immature_female'	=> ['immature_female', /\A([0-9]+)?\z/],
		'immature_unknown'	=> ['immature_unknown', /\A([0-9]+)?\z/],
		'adult_male'		=> ['adult_male', /\A([0-9]+)?\z/],
		'adult_female'		=> ['adult_female', /\A([0-9]+)?\z/],
		'adult_unknown'		=> ['adult_unknown', /\A([0-9]+)?\z/],
		'unknown_male'		=> ['unknown_male', /\A([0-9]+)?\z/],
		'unknown_female'	=> ['unknown_female', /\A([0-9]+)?\z/],
		'unknown_unknown'	=> ['unknown_unknown', /\A([0-9]+)?\z/],
		'notes'			=> ['notes', /.*/],
		'link'			=> ['link', /.*/],
		'tags'			=> ['tag_list', /.*/],
		'omit'			=> ['omit', /.*/]
	}

	REQUIRED = [
		'english name'
	]

	column :file,		:binary
	column :filename,	:string
	column :description,	:text
	column :user_id,	:integer
	column :pending_import_id, :integer
	column :ebird_exclude, 	:boolean

	belongs_to :user
	belongs_to :pending_import

	attr_accessible :file, :description, :ebird_exclude

	validates_presence_of	:file, :user_id

        def validate
          if self.file.blank? then
            return
          end

          if self.file.size > 150.kilobyte then
            errors.add(:file, 'must be smaller than 150 KB')
            return
          end

          items_per_batch = 100
          line = 1
          begin
            # This ensures that all of our additions are stuck in a single transaction (faster)
            PendingImport.transaction do
              pending_import_items = []
              CSV::Reader.parse(self.file, nil, determine_line_ending(self.file)) do |row|
                row = row.collect{|i| i.to_s.strip}
                unless @header then
                  return unless valid_header?(row)
                else
                  begin
                    pending_import_items.push(parse_row(row, line))
                  rescue
                    return
                  end
                end

                if(pending_import_items.size > 0 and
                   pending_import_items.size % items_per_batch == 0) then
                  insert_pending_import_item_batch(pending_import_items)
                end

                line += 1
              end

              # Catch any stragglers
              if(pending_import_items.size > 0) then
                insert_pending_import_item_batch(pending_import_items)
              end
            end
          rescue
            errors.add(:file, 'CSV formatting error on line ' + line.to_s)
            logger.info "CSV Error: " + $!
          end

          unless @header then
            errors.add(:file, 'contains no header')
          end
        end

	def after_validation
		unless self.errors.on(:file) then
			self.filename = self.file.original_filename
			errors.add(:file, 'has no filename') unless self.filename
		end
	end

	private

        def insert_pending_import_item_batch(pending_import_items)
          return if pending_import_items.size == 0

          # I hand code the SQL here because the speed is well worth it.
          # Plus, we don't really need validation at this point.
          
          common_keys = Set.new
          pending_import_items.each do |item|
            common_keys.merge(item.keys)
          end

          common_keys = common_keys.to_a # need a predictable order

          conn = self.connection

          statement = "INSERT INTO pending_import_items (#{common_keys.join(',')}) VALUES "
          pending_import_items.each do |item|
            statement += "(#{common_keys.collect {|k| conn.quote(item[k])}.join(',')}),"
          end

          statement.chop! # remove the trailing comma

          conn.execute(statement)

          pending_import_items.clear
        end

	def valid_header?(row)
		@header = []
		row.each do |col|
                  col.downcase!
                  unless COLUMNS[col] then
                    # If the header has non-ASCII bytes, chances are that it's not CSV
                    col.each_byte do |b|
                      if(b > 127) then
                        errors.add(:file, 'does not appear to be a valid CSV file')
                        return false
                      end
                    end

                    errors.add(:file, 'contains unrecognized header column: ' + col.to_s.first(35))
                    return false
                  else
                    @header << COLUMNS[col]
                  end
		end

                # For the uniqueness test, ignore omit columns, we allow duplicates of those
                @uniq_header = @header.find_all {|col| col != COLUMNS['omit']}
		if @uniq_header.uniq != @uniq_header then
			errors.add(:file, 'contains duplicated header columns')
		end

		REQUIRED.each do |col|
			 unless @header.include? COLUMNS[col] then
				errors.add(:file, 'is missing required header column: ' + col)
				return false
			 end
		end

		header_field_names = @header.collect {|i| i[0]}

		if header_field_names.include? '_mdy_date' then
			errors.add(:file, 'contains DMY Date not allowed with MDY Date') if header_field_names.include? '_dmy_date'
			errors.add(:file, 'contains ISO Date not allowed with MDY Date') if header_field_names.include? '_iso_date'
			errors.add(:file, 'contains Year not allowed with MDY Date') if header_field_names.include? 'date_year'
			errors.add(:file, 'contains Month not allowed with MDY Date') if header_field_names.include? 'date_month'
			errors.add(:file, 'contains Day not allowed with MDY Date') if header_field_names.include? 'date_day'
		elsif header_field_names.include? '_dmy_date' then
			errors.add(:file, 'contains MDY Date not allowed with DMY Date') if header_field_names.include? '_mdy_date'
			errors.add(:file, 'contains ISO Date not allowed with DMY Date') if header_field_names.include? '_iso_date'
			errors.add(:file, 'contains Year not allowed with DMY Date') if header_field_names.include? 'date_year'
			errors.add(:file, 'contains Month not allowed with DMY Date') if header_field_names.include? 'date_month'
			errors.add(:file, 'contains Day not allowed with DMY Date') if header_field_names.include? 'date_day'
		elsif header_field_names.include? '_iso_date' then
			errors.add(:file, 'contains MDY Date not allowed with ISO Date') if header_field_names.include? '_mdy_date'
			errors.add(:file, 'contains DMY Date not allowed with ISO Date') if header_field_names.include? '_dmy_date'
			errors.add(:file, 'contains Year not allowed with ISO Date') if header_field_names.include? 'date_year'
			errors.add(:file, 'contains Month not allowed with ISO Date') if header_field_names.include? 'date_month'
			errors.add(:file, 'contains Day not allowed with ISO Date') if header_field_names.include? 'date_day'
		end

		if header_field_names.include? '_12hr_time' then
			errors.add(:file, 'contains 24-hour time not allowed with 12-hour time') if header_field_names.include? '_24hr_time'
			errors.add(:file, 'contains 24-hour hour not allowed with 12-hour time') if header_field_names.include? 'time_hour'
			errors.add(:file, 'contains minute not allowed with 12-hour time') if header_field_names.include? 'time_minute'
		elsif header_field_names.include? '_24hr_time' then
			errors.add(:file, 'contains 12-hour time not allowed with 12-hour time') if header_field_names.include? '_12hr_time'
			errors.add(:file, 'contains 24-hour hour not allowed with 12-hour time') if header_field_names.include? 'time_hour'
			errors.add(:file, 'contains minute not allowed with 12-hour time') if header_field_names.include? 'time_minute'
		end
		
		return errors.empty?
	end

	def parse_row(row, line)
		return unless row.size > 0
		pending_import_item = {'line' => line, 'pending_import_id' => self.pending_import.id}
		0.upto(row.size-1) do |i|
			next if row[i].blank?
			if @header[i][0] == '_dmy_date' then
				unless row[i] =~ /(\d+)?\/(\d+)?\/(\d+)?/ then
					errors.add(:file, 'column ' + (i+1).to_s + ' failed validation on line ' + line.to_s)
					raise
				end
				pending_import_item['date_day'] = $1
				pending_import_item['date_month'] = $2
				pending_import_item['date_year'] = $3
			elsif @header[i][0] == '_mdy_date' then
				unless row[i] =~ /(\d+)?\/(\d+)?\/(\d+)?/ then
					errors.add(:file, 'column ' + (i+1).to_s + ' failed validation on line ' + line.to_s)
					raise
				end
				pending_import_item['date_month'] = $1
				pending_import_item['date_day'] = $2
				pending_import_item['date_year'] = $3
			elsif @header[i][0] == '_iso_date' then
				unless row[i] =~ /(\d+)?-(\d+)?-(\d+)?/ then
					errors.add(:file, 'column ' + (i+1).to_s + ' failed validation on line ' + line.to_s)
					raise
				end
				pending_import_item['date_year'] = $1
				pending_import_item['date_month'] = $2
				pending_import_item['date_day'] = $3
			elsif @header[i][0] == '_12hr_time' then
				unless row[i] =~ /(\d+):(\d+)\s*(p)?/i then
					errors.add(:file, 'column ' + (i+1).to_s + ' failed validation on line ' + line.to_s)
					raise
				end
				pending_import_item['time_hour'] = $1 ? ($1.to_i + ($3 ? 12 : 0)) : nil
				pending_import_item['time_hour'] = 0 if pending_import_item['time_hour'] == 24
				pending_import_item['time_minute'] = $2
			elsif @header[i][0] == '_24hr_time' then
				unless row[i] =~ /(\d+):(\d+)/ then
					errors.add(:file, 'column ' + (i+1).to_s + ' failed validation on line ' + line.to_s)
					raise
				end
				pending_import_item['time_hour'] = $1
				pending_import_item['time_minute'] = $2
			elsif @header[i][0] == 'species_count' then
				if row[i] =~ /\Ax\z/i then
					# Do nothing
				elsif row[i] =~ /\A([0-9]+)?\z/ then
					pending_import_item['species_count'] = row[i]
				else
					errors.add(:file, 'column ' + (i+1).to_s + ' failed validation on line ' + line.to_s)
				end
			elsif @header[i][0] == 'omit' then
                          # Do nothing
			elsif @header[i][0] =~ /^_/ then
				raise 'Unknown virtual column: ' + header[i]
			else
				unless row[i] =~ @header[i][1] then
					errors.add(:file, 'column ' + (i+1).to_s + ' failed validation on line ' + line.to_s)
					raise
				end

				pending_import_item[@header[i][0]] = row[i]
			end
		end
		return pending_import_item
	end
	
	# Read the specified file and determine the appropriate line ending by looking  
	# for the first line-ending.  
	# Adapted from: http://dev.rubyonrails.org/ticket/2117
	# Specifically designed for the CSV module
	def determine_line_ending(file)    
		delimiter = nil
		saw_cr = false
		file.each_byte do |c|  
			if c == ?\n  
				delimiter = nil # Let CSV take care of it
				break
			elsif c == ?\r then
				saw_cr = true
			elsif saw_cr then
				if c == ?\n then
					delimiter = nil # Let CSV take care of it
					break
				else
					delimiter = ?\r
					break
				end
			end
		end

		file.rewind
		return delimiter
	end
end
