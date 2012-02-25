require "#{File.dirname(__FILE__)}/../test_helper"

class TaxaRedirectTest < ActionController::IntegrationTest
	def test_no_redir_species
		get '/world-bird-list/podicipediformes/podicipedidae/aechmophorus/occidentalis'
	end

	def test_redir_species
		get '/world-bird-list/podicipediformes/podicipedidae/aechmophorus/occidentalisINVALID'
		assert_redirected_to '/world-bird-list/podicipediformes/podicipedidae/aechmophorus'
		assert flash.has_key?(:warning)
	end

	def test_redir_family
		get '/world-bird-list/podicipediformes/INVALIDpod1icipedidae/aechmophorus/occidentalis'
		follow_redirect!
		follow_redirect!
		assert_redirected_to '/world-bird-list/podicipediformes'
	end
end
