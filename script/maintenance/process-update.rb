include Birdstack::Resort

$stdout.sync = true

# Have to do this madness because of Incertae Sedis
def resolve_family(desc)
  family = nil
  if desc.instance_of?(Hash) then
    if desc[:id] then
      family = Family.find(desc[:id])
      return family if family
    end
    if desc[:included_genus] then
      family = Genus.find_by_latin_name(desc[:included_genus]).family
      return family if family
    end
    if desc[:name] then
      family = Family.find_by_latin_name(desc[:name])
      return family if family
    end
  else
    family = Family.find_by_latin_name(desc)
    return family if family
  end

  raise "Could not find family with this description: #{desc}"
end

def species_updates(updates)
  updates = [updates].flatten

  puts "Processing species updates"
  updates.each do |s|
	# Find the original (use :original if given, otherwise assume that :english_name is ok)
        search_name = s[:original] || s[:english_name]
	puts search_name
	original = Species.find_valid_by_exact_english_name(search_name) or raise "Could not find original #{search_name}"

	[:english_name, :latin_name, :breeding_subregions, :nonbreeding_regions, :note, :code].each do |field|
		original[field] = s[field] if s.has_key?(field)
	end
	if(!s[:breeding_ranges].nil?) then
		original.regions = s[:breeding_ranges].split(/,\s*/).collect do |range|
			Region.find_by_code(range) or raise "Could not find region #{range}"
		end
	end
	if(!s[:genus].nil?) then
		original.genus = Genus.find_by_latin_name(s[:genus])
	end

	if(!s[:sort_after].nil?) then
          if(s[:sort_after] == :first) then
            insert_first(original)
          else
            sort_after = Species.find_valid_by_exact_english_name(s[:sort_after]) or raise "Could not find sort_after #{s[:sort_after]}"
            insert_after(sort_after, original)
          end
	end

	original.save!
  end
end
alias :species_update :species_updates

def species_lumps(updates)
  updates = [updates].flatten

  puts "Processing species lumps"
  updates.each do |u|
    u.each_pair do |s,c|
      puts s
      original = nil
      if(c[:id]) then
        original = Species.find(c[:id])
      else
        original = Species.find_valid_by_exact_english_name(s) or raise "Could not find original #{s}"
      end

      potential = Species.find_valid_by_exact_english_name(c[:species]) or raise "Could not find potential #{c[:species]}"

      change = Change.new
      change.change_type = 'lump'
      change.date = Time::now()
      change.description = c[:description]
      change.potential_species << potential
      change.save!
      original.change = change
      original.save!
    end
  end
end
alias :species_lump :species_lumps

def species_splits(updates)
  updates = [updates].flatten

  puts "Processing species splits"
  updates.each do |s|
	puts s[:original]
	# Find the original
	original = Species.find_valid_by_exact_english_name(s[:original]) or raise "Could not find original #{s[:original]}"

	# Create potentials
	potentials = s[:potentials].collect do |potential|
		p = original.clone
		[:english_name, :latin_name, :breeding_subregions, :nonbreeding_regions, :note, :code].each do |field|
			p[field] = potential[field] if potential.has_key?(field)
		end
		if(potential[:breeding_ranges].nil?) then
			p.regions = original.regions # not covered by clone
		else
			p.regions = potential[:breeding_ranges].split(/,\s*/).collect do |range|
				Region.find_by_code(range) or raise "Could not find region #{range}"
			end
		end
		if(!s[:genus].nil?) then
			original.genus = Genus.find_by_latin_name(s[:genus])
		end

		if(potential[:sort_after].nil?) then
                  # If they did not specify a sort_after, plunk it in right after the 'original'
                  insert_after(original, p)
		else
                  if(potential[:sort_after] == :first) then
                    insert_first(p)
                  else
                    # If they specified a sort_after, we want to find a record that matches the english name, does not have a change associated with it, and is not our 'original' record (which will soon have a change associated with it)
                    sort_after = Species.find(:first, :conditions => [ 'english_name = ? AND change_id IS NULL AND id != ?', potential[:sort_after], original.id]) or raise "Could not find sort_after #{potential[:sort_after]}"
                    insert_after(sort_after, p)
                  end
		end

                p
	end

	change = Change.new
	change.change_type = 'split'
	change.date = Time::now()
	change.description = s[:description]
	change.potential_species = potentials
	change.save!
	original.change = change
	original.save!
  end
end
alias :species_split :species_splits

def genus_deletes(updates)
  updates = [updates].flatten

  puts "Processing genus deletes"
  updates.each do |g|
    search_name = g[:original] || g[:latin_name]
    puts search_name
    original = Genus.find_by_latin_name(search_name) or raise "Could not find original #{search_name}"

    original.species.reload # Make sure we haven't cached an old value
    if original.species.size > 0 then
      original.species.each do |s|
        puts "associated: #{s.inspect}"
      end
      raise "Still has species associated with it #{search_name}"
    end

    original.destroy
  end
end
alias :genus_delete :genus_deletes

def species_deletes(updates)
  updates = [updates].flatten

  puts "Processing species deletes"
  updates.each do |u|
    u.each_pair do |s,d|
      puts s
      original = Species.find_valid_by_exact_english_name(s) or raise "Could not find original #{s}"

      original.sightings.reload # No caching
      raise "Somebody saw this one #{s}" if original.sightings.size > 0

      # Should be safe to permanently delete
      original.destroy
    end
  end
end
alias :species_delete :species_deletes

def family_deletes(updates)
  updates = [updates].flatten

  puts "Processing family deletes"
  updates.each do |f|
    search_name = f[:original] || f[:latin_name]

    original = (Family.find_by_id(f[:id]) || Family.find_by_latin_name(search_name)) or raise "Could not find original #{search_name}"

    puts original.latin_name

    original.genera.reload # Make sure we haven't cached an old value
    if original.genera.size > 0 then
      original.genera.each do |g|
        puts "associated: #{g.inspect}"
      end
      raise "Still has genera associated with it #{search_name}"
    end

    original.destroy
  end
end
alias :family_delete :family_deletes

def family_updates(updates)
  updates = [updates].flatten

  puts "Processing family updates"
  updates.each do |f|
	puts f[:original]
	# Find the original
	original = (Family.find_by_id(f[:id]) || Family.find_by_latin_name(f[:original])) or raise "Could not find original #{f[:original]}"

	[:english_name, :latin_name, :note, :code].each do |field|
		original[field] = f[field] if f.has_key?(field)
	end

        if(!f[:order].nil?) then
          original.order = Order.find_by_latin_name(f[:order])
        end

	if(!f[:sort_after].nil?) then
          if(f[:sort_after] == :first) then
            insert_first(original)
          else
            sort_after = resolve_family(f[:sort_after])
            insert_after(sort_after, original)
          end
	end

	original.save!
  end
end
alias :family_update :family_updates

def genus_new(updates)
  updates = [updates].flatten

  puts "Processing new genera"
  updates.each do |g|
    puts g[:latin_name]

    ng = Genus.new
    [:latin_name, :note, :code].each do |field|
      ng[field] = g[field] if g.has_key?(field)
    end

    ng.family = resolve_family(g[:family]) or raise "Could not find family #{g[:family]}"
    if(g[:sort_after] == :first) then
      insert_first(ng)
    else
      sort_after = Genus.find_by_latin_name(g[:sort_after]) or raise "Couldn't find sort_after #{s[:sort_after]}"
      insert_after(sort_after, ng)
    end
    ng.save!
  end
end

def species_new(updates)
  updates = [updates].flatten

  puts "Processing new species"
  updates.each do |s|
	puts s[:english_name]
	ns = Species.new

	[:english_name, :latin_name, :breeding_subregions, :nonbreeding_regions, :note, :code].each do |field|
		ns[field] = s[field] if s.has_key?(field)
	end
	if(!s[:breeding_ranges].nil?) then
		ns.regions = s[:breeding_ranges].split(/,\s*/).collect do |range|
			Region.find_by_code(range) or raise "Could not find region #{range}"
		end
	end
	if(!s[:genus].nil?) then
		ns.genus = Genus.find_by_latin_name(s[:genus])
	end

        if(s[:sort_after] == :first) then
          insert_first(ns)
        else
          sort_after = Species.find_valid_by_exact_english_name(s[:sort_after]) or raise "Could not find sort_after #{s[:sort_after]}"
          insert_after(sort_after, ns)
        end

	ns.save!
  end
end

def order_new(updates)
  updates = [updates].flatten

  puts "Processing new orders"
  updates.each do |o|
    puts o[:latin_name]
    no = Order.new
    [:latin_name, :note, :code].each do |field|
      no[field] = o[field] if o.has_key?(field)
    end

    if(o[:sort_after] == :first) then
      insert_first(no)
    else
      sort_after = Order.find_by_latin_name(o[:sort_after]) or raise "Could not find sort_after order #{o[:sort_after]}"

      insert_after(sort_after, no)
    end
  end
end

def family_new(updates)
  updates = [updates].flatten

  puts "Processing new families"
  ret = []
  updates.each do |f|
	puts f[:english_name]
	nf = Family.new
	nf.order = Order.find_by_latin_name(f[:order]) or raise "Could not find order #{f[:order]}"
	[:english_name, :latin_name, :note, :code].each do |field|
		nf[field] = f[field] if f.has_key?(field)
	end

        if(f[:sort_after] == :first) then
          insert_first(nf)
        else
          sort_after = resolve_family(f[:sort_after]) or raise "Could not find sort_after family #{f[:sort_after]}"

          insert_after(sort_after, nf)
        end

        ret << nf
  end

  ret
end

def genus_updates(updates)
  updates = [updates].flatten

  puts "Processing genus updates"
  updates.each do |g|
	# Find the original (assume :latin_name if no :original)
        search_name = g[:original] || g[:latin_name]
	puts search_name
	original = Genus.find_by_latin_name(search_name) or raise "Could not find original #{search_name}"

	[:latin_name, :note, :code].each do |field|
		original[field] = g[field] if g.has_key?(field)
	end

	if g[:family] then
		original.family = resolve_family(g[:family]) or raise "Could not find family #{g[:family]}"
	end

	if(!g[:sort_after].nil?) then
          if(g[:sort_after] == :first) then
            insert_first(original)
          else
            sort_after = Genus.find_by_latin_name(g[:sort_after]) or raise "Could not find sort_after #{g[:sort_after]}"
            insert_after(sort_after, original)
          end
	end

	original.save!
  end
end
alias :genus_update :genus_updates

def order_updates(updates)
  updates = [updates].flatten

  puts "Processing order updates"
  updates.each do |o|
	puts o[:original]
	# Find the original
	original = Order.find_by_latin_name(o[:original]) or raise "Could not find original #{o[:original]}"

	[:latin_name, :note, :code].each do |field|
		original[field] = o[field] if o.has_key?(field)
	end

	if(!o[:sort_after].nil?) then
          if(o[:sort_after] == :first) then
            insert_first(original)
          else
            sort_after = Order.find_by_latin_name(o[:sort_after]) or raise "Could not find sort_after #{g[:sort_after]}"
            insert_after(sort_after, original)
          end
	end

	original.save!
  end
end
alias :order_update :order_updates

Species.transaction do

require ARGV[0]

# Do final reorder pass
puts "Final reordering pass"
orders = Birdstack::ParseCSV.parse_ioc_csv(ARGV[1])

prev_o = nil
orders.each do |fake_o|
  o = Order.find_by_latin_name(fake_o.latin_name) or raise "Couldn't find order #{fake_o.latin_name}"
  insert_after(prev_o, o)
  prev_o = o

  prev_f = nil
  fake_o.families.each do |fake_f|
    # Have to do this stupid stuff because of incertae sedis
    # Finding a constituent species and working back should be unique
    f = Genus.find_by_latin_name(fake_f.genera[0].latin_name).andand.family
    if f.nil? or f.order != o then
      raise "Couldn't find family #{fake_f.latin_name} in order #{o.latin_name}"
    end

    insert_after(prev_f, f)
    prev_f = f

    prev_g = nil
    fake_f.genera.each do |fake_g|
      g = f.genera.find_by_latin_name(fake_g.latin_name) or raise "Couldn't find genus #{fake_g.latin_name} in family #{f.latin_name}"
      insert_after(prev_g, g)
      prev_g = g

      prev_s = nil
      fake_g.species.each do |fake_s|
        s = g.species.valid.find_by_latin_name(fake_s.latin_name)
        unless s then
          #require 'ruby-debug'
          #debugger
          raise "Couldn't find species #{g.latin_name} #{fake_s.latin_name}"
        end
        insert_after(prev_s, s)
        prev_s = s
      end
    end
  end
end

# Generate sort_orders
puts "Updating sort_order"
gen_sort_orders

# Update caches

puts "Updating caches"
Genus.find(:all).each {|g| g.update_cache }
Family.find(:all).each {|f| f.update_cache }
Order.find(:all).each {|o| o.update_cache }

puts "Verifying against CSV"

results = Birdstack::VerifyDB.verify(ARGV[1])

if results[:errors].size > 0 then
	puts results[:errors].join("\n")
	puts "#{results[:errors].size} errors found"
        puts "DB CSV:"
        puts results[:db_csv].join("\n")
	raise 'The database does not fully match the csv'
end

puts "Loaded and verified!  You rock!"

puts "Updating user caches"

User.find(:all).each {|u| u.update_cached_counts or raise 'error updating user cache!' }

puts "Closing transaction!"

end
