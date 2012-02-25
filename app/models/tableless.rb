# http://www.bphogan.com/learn/pdf/tableless_contact_form.pdf

class Tableless < ActiveRecord::Base
	# This is a table-less model
	def self.columns() @columns ||= []; end
	def self.column(name, sql_type = nil, default = nil, null = true)
		columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
	end

	def save(validate = true)
		validate ? valid? : true
	end
end
