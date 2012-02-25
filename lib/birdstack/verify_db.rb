require 'csv'

module Birdstack::VerifyDB
        private

        def self.fix_nils(line)
          line = line.collect do |e|
            if(e.andand.empty?) then
              e = nil
            else
              e
            end
          end
          while(line.size > 0 and line[-1].nil?)
            line.pop
          end

          line
        end

        def self.compare_db_csv_line(line, db_line, errors, db_csv)
          line = CSV.generate_line(fix_nils(line))
          db_line = CSV.generate_line(fix_nils(db_line))
          if line != db_line then
            errors << "* CSV: #{line}"
            errors << "|  DB: #{db_line}"
          end

          db_csv << db_line
        end

        public

	def verify(csv_filename)
		errors = []
                db_csv = []

		csv = CSV.open(csv_filename, 'r')

		csv.shift # skip header

                # We need to make sure they keep increasing by one, even across level boundaries
                old_order_sort = 0
                old_family_sort = 0
                old_genus_sort = 0
                old_species_sort = 0

		Order.find(:all, :order => 'sort_order').each do |o|
			line = csv.shift

                        compare_db_csv_line(line,[o.latin_name,nil,nil,nil,nil,nil,nil,nil,nil,o.code,o.note], errors, db_csv)

                        unless o.sort_order == old_order_sort.andand + 1 then
                          errors << "order sort_order unexpected. old: #{old_order_sort}, CSV: #{line.join(',')}, DB: #{o.inspect}"
                        end

                        old_order_sort = o.sort_order

			o.families.find(:all, :order => 'sort_order').each do |f|
				line = csv.shift

                                compare_db_csv_line(line,[nil,f.latin_name,f.english_name,nil,nil,nil,nil,nil,nil,f.code,f.note], errors, db_csv)

                                unless f.sort_order == old_family_sort.andand + 1 then
                                  errors << "family sort_order unexpected. old: #{old_family_sort}, CSV: #{line.join(',')}, DB: #{f.inspect}"
                                end
                                old_family_sort = f.sort_order

				f.genera.find(:all, :order => 'sort_order').each do |g|
					line = csv.shift

                                        compare_db_csv_line(line,[nil,nil,nil,g.latin_name,nil,nil,nil,nil,nil,g.code,g.note], errors, db_csv)

                                        unless g.sort_order == old_genus_sort.andand + 1 then
                                          errors << "genus sort_order unexpected. old: #{old_genus_sort}, CSV: #{line.join(',')}, DB: #{g.inspect}"
                                        end
                                        old_genus_sort = g.sort_order

					g.species.find(:all, :include => :regions, :conditions => [ 'change_id IS NULL' ], :order => 'sort_order').each do |s|
						line = csv.shift

                                                # To ensure we're comparing equivalent region lists, sort them on both sides
                                                # In the actual db, it's just a one-to-many relationship without sorting,
                                                # but here we compare equivalent CSV lines, so the order does matter

                                                line[6] = line[6].to_s.split(/,\s*/).sort.join(', ')

                                                compare_db_csv_line(line,[nil,nil,nil,nil,
                                                  s.latin_name,
                                                  s.english_name,
                                                  s.regions.collect {|r| r.code }.sort.join(', '), # sort here too
                                                  s.breeding_subregions.andand.empty? ? nil : s.breeding_subregions,
                                                  s.nonbreeding_regions.andand.empty? ? nil : s.nonbreeding_regions,
                                                  s.code,
                                                  s.note
                                                  ], errors, db_csv)
						
                                                # Because of old species, the sort order may increase by more than 1
                                                if old_species_sort.nil? or !(s.sort_order.andand > old_species_sort) then
                                                  errors << "species sort_order unexpected. old: #{old_species_sort}, CSV: #{line.join(',')}, DB: #{s.inspect}"
                                                end
                                                old_species_sort = s.sort_order
					end
				end
			end
		end

                if !csv.shift.empty? then
                  errors << "Lines remain in CSV!"
                end

		return {:errors => errors, :db_csv => db_csv}
	end

	module_function :verify
end
