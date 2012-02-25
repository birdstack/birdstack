class Location < ActiveRecord::Base
	def adm1_name
		primary_adm1 = PrimaryAdm1.find(:first, :conditions => ['cc = ? AND adm1 = ?', self.cc, self.adm1])
		if primary_adm1 then
			name = primary_adm1.adm1.name
		else
			name = '(' + self.cc + self.adm1 + ')'
		end

		name
	end
end
