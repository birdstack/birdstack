require File.dirname(__FILE__) + '/../test_helper'

class ImportControllerTest < ActionController::TestCase
	def test_invalid_date_display
		file = ActionController::UploadedStringIO.new("english name,dmy date\nWild Monkey,100/100/10000000")
		import_file = ImportFile.new(:file => file)

		import_file.user = users(:joe)

		pending_import = PendingImport.new
		pending_import.user = users(:joe)
		pending_import.filename = 'test.txt'
		pending_import.save!

		import_file.pending_import = pending_import

		assert import_file.save

		login_as(:joe)
		get :pending, :id => pending_import.id
		assert_response :success
	end
end
