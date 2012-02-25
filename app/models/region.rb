class Region < ActiveRecord::Base
	attr_accessible

	has_and_belongs_to_many	:species
end
