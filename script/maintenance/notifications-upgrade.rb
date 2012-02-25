@@notifications = []

def species_updates(updates)
  updates = [updates].flatten

  updates.each do |s|
        next unless s[:original] and s[:english_name]
        n = Species.find_valid_by_exact_english_name(s[:english_name]).andand.notification
        if(n) then
          @@notifications << n
        end
  end
end
alias :species_update :species_updates

def species_splits(updates)
end
alias :species_split :species_splits
def species_lumps(updates)
end
alias :species_lump :species_lumps
def genus_deletes(updates)
end
alias :genus_delete :genus_deletes
def species_deletes(updates)
end
alias :species_delete :species_deletes
def family_deletes(updates)
end
alias :family_delete :family_deletes
def family_updates(updates)
end
alias :family_update :family_updates
def genus_new(updates)
end
def species_new(updates)
end
def family_new(updates)
end
def genus_updates(updates)
end
alias :genus_update :genus_updates
def order_updates(updates)
end
alias :order_update :order_updates
def order_new(update)
end

# Find all alternate names that are associated with species that have had their english name changed
require ARGV[0] if ARGV[0]

# Find notifications for species that have a change_id, meaning they are out of date
@@notifications += Notification.find(:all, :conditions => ['species.change_id IS NOT NULL'], :joins => 'LEFT JOIN species ON notifications.species_id = species.id')

# Find notifications that reference species with a change_id
@@notifications += Notification.find(:all, :conditions => ['species.change_id is not null'], :joins => 'left join notifications_species on notifications.id = notifications_species.notification_id left join species on notifications_species.species_id = species.id')

# Find notifications that fail their validation checks
@@notifications += Notification.find(:all).find_all {|n| !n.valid?}

# Only unique ones
@@notifications.uniq!

Species.transaction do
  @@notifications.each do |n|
    n.interactive_editor
    puts "---"
  end
end
