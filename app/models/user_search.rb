class UserSearch < Tableless
	column :login,		:string
	validates_length_of	:login, :minimum => 3, :allow_blank => true
	column :cc,		:string
	column :location,	:string
	validates_length_of	:location, :minimum => 3, :allow_blank => true
	column :tags,		:string

	attr_accessible :login, :cc, :location, :tags

	def search(search_params = {})
		return unless self.valid?
		
		# If there are no other errors, make sure they specified something
		if self.login.blank? and self.cc.blank? and self.location.blank? and self.tags.blank?
			return
		end

		conditions = 'activated_at IS NOT NULL'
		params = []

		[:login, :location].find_all {|i| !self.send(i).blank? }.each do |i|
			conditions += " AND users.#{i.to_s} LIKE ?"
			params << '%' + self.send(i) + '%'
		end
		if !self.cc.blank? then
			conditions += " AND users.cc = ?"
			params << self.cc
		end

		if self.tags.blank? then
			return User.paginate({:conditions => [conditions, *params], :order => 'users.login'}.merge(search_params))
		else
			return User.paginate_tagged_with(self.tags, {:conditions => [conditions, *params], :order => 'users.login'}.merge(search_params))
		end
	end
end
