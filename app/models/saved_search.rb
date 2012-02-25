class SavedSearch < ActiveRecord::Base
	belongs_to		:user

	attr_accessible		:name, :search, :private

	validates_presence_of	:search
	validates_presence_of	:user_id
	# Temp searches aren't expected to have names
	validates_presence_of	:name, :unless => :temp
	validates_uniqueness_of	:name, :unless => :temp, :scope => :user_id
	validates_inclusion_of	:private, :in => [true, false], :allow_nil => true
	validates_inclusion_of	:temp, :in => [true, false], :message => 'is not valid'

	# Saved searches are also considered private when they are marked as temp
	def publicize!(user = nil)
		if @publicized and @publicized_for != user then
			raise 'Attempted to republicize saved search ' + self.id.to_s + ' for ' + user.to_s + ' when already publicized for ' + @publicized_for.to_s
		end

		return self if @publicized

		if self.user == user then
			# Do nothing
		elsif self.private or self.temp then
			raise 'Attempted to publicize private or temporary saved search ' + self.id.to_s
		else
			# Scrub our private status
			self.private = nil
		end

		@publicized = true
		@publicized_for = user

		self.readonly!
		self.freeze
		
		return self
	end

	# Not necessarily private
	def self.find_nontemp_by_id(id)
		saved_search = send(:find, :first, :conditions => ['saved_searches.id = ? AND saved_searches.temp = 0', id])
		return saved_search
	end

	# This also ensures that the saved search isn't temp
	def self.find_public_by_id(id, user = nil)
		saved_search = send(:find, :first, :conditions => ['saved_searches.id = ? AND (saved_searches.private IS NULL OR saved_searches.private = 0) AND saved_searches.temp = 0', id])
		saved_search.publicize!(user) if saved_search
		return saved_search
	end
	
	# This accepts an options hash, but will not carry across any conditions specified
	# This ensures that the saved search isn't private or temp
	def self.find_public_by_user(user, publicize_for = nil, options = {})
		options[:order] ||= 'user_locations.name'
		results = send(:find, :all, options.merge({:conditions => ['saved_searches.user_id = ? AND (saved_searches.private IS NULL OR saved_searches.private = 0) AND saved_searches.temp = 0', user.id]}))
		results.each {|search| search.publicize!(publicize_for) }
		return results
	end
end
