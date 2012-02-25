require File.dirname(__FILE__) + '/../test_helper'
require 'ioc_controller'

# Re-raise errors caught by the controller.
class IocController; def rescue_action(e) raise e end; end

class IocControllerTest < ActionController::TestCase
  def setup
    @controller = IocController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

	def test_old_species
		s = users(:quentin).sightings.find(:first).species
		get :species, :order => s.genus.family.order.latin_name, :family => s.genus.family.latin_name, :genus => s.genus.latin_name, :species => s.latin_name

		old_id = Species.find_valid_by_exact_english_name(s.english_name).id
		assert @response.body =~ /\/sighting\/add\/#{old_id}/

		change = Change.new
		change.species = s
		change.change_type = 'removal'
		change.description = 'cheese'
		change.date = Time::now()
		change.save!

		get :species, :order => s.genus.family.order.latin_name, :family => s.genus.family.latin_name, :genus => s.genus.latin_name, :species => s.latin_name

		# We shouldn't find this species any more because it's been deleted
		assert_nil @response.body =~ /\/sighting\/add\/#{old_id}/
	end

	def test_old_species_on_genus_page
		s = users(:quentin).sightings.find(:first).species
		get :genus, :order => s.genus.family.order.latin_name, :family => s.genus.family.latin_name, :genus => s.genus.latin_name

		assert @response.body =~ /#{s.genus.family.order.latin_name}\/#{s.genus.family.latin_name}\/#{s.genus.latin_name}\/#{s.latin_name}/


		change = Change.new
		change.species = s
		change.change_type = 'removal'
		change.description = 'cheese'
		change.date = Time::now()
		change.save!

		get :genus, :order => s.genus.family.order.latin_name, :family => s.genus.family.latin_name, :genus => s.genus.latin_name, :species => s.latin_name

		# We shouldn't find this species any more because it's been deleted
		assert_nil @response.body =~ /#{s.genus.family.order.latin_name}\/#{s.genus.family.latin_name}\/#{s.genus.latin_name}\/#{s.latin_name}/
	end
end
