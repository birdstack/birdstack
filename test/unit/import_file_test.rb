require File.dirname(__FILE__) + '/../test_helper'

class ImportFileTest < ActiveSupport::TestCase
        def test_no_file_validation
          import_file = ImportFile.new
          import_file.user = users(:joe)

          pending_import = PendingImport.new
          pending_import.user = users(:joe)
          pending_import.filename = 'test.csv'
          pending_import.save!

          import_file.pending_import = pending_import

          assert !import_file.save
          assert import_file.errors.on(:file)
        end

	def test_cr_delimiter
		file = ActionController::UploadedStringIO.new("english name\rWild Monkey")
		import_file = create_import_file(file)

		assert import_file.save 
		assert_equal 1, import_file.pending_import.pending_import_items.size
	end

	def test_crlf_delimiter
		file = ActionController::UploadedStringIO.new("english name\r\nWild Monkey")
		import_file = create_import_file(file)

		assert import_file.save 
		assert_equal 1, import_file.pending_import.pending_import_items.size
	end

	def test_lf_delimiter
		file = ActionController::UploadedStringIO.new("english name\nWild Monkey")
		import_file = create_import_file(file)

		assert import_file.save 
		assert_equal 1, import_file.pending_import.pending_import_items.size
	end

	def test_crlf_delimiter_with_bom
		# Access will put this at the beginning of the file if you choose unicode
		file = ActionController::UploadedStringIO.new("\357\273\277english name\r\nWild Monkey")
		import_file = create_import_file(file)

		assert import_file.save 
		assert_equal 1, import_file.pending_import.pending_import_items.size
	end

	def test_x_number
		file = ActionController::UploadedStringIO.new("english name,number observed\nWild Monkey,x")
		import_file = create_import_file(file)

		assert import_file.save 
		assert_equal 1, import_file.pending_import.pending_import_items.size
		assert_nil import_file.pending_import.pending_import_items[0].species_count
	end

	def test_no_other_strings_number
		file = ActionController::UploadedStringIO.new("english name,number observed\nWild Monkey,thisstringhasxinit")
		import_file = create_import_file(file)

		assert !import_file.save 
	end

	def test_blank_dmy_day
		file = ActionController::UploadedStringIO.new("english name,dmy date\nWild Monkey,/3/1985")
		import_file = create_import_file(file)

		assert import_file.save 
		assert_equal 1, import_file.pending_import.pending_import_items.size
		item = import_file.pending_import.pending_import_items[0]
		assert_equal nil, item.date_day
		assert_equal 3, item.date_month
		assert_equal 1985, item.date_year
                assert_equal "Wild Monkey", item.english_name
	end

	def test_link_and_tag_list
		file = ActionController::UploadedStringIO.new("english name,link,tags\nWild Monkey,google.com,beans")
		import_file = create_import_file(file)

		assert import_file.save 
		assert_equal 1, import_file.pending_import.pending_import_items.size

		item = import_file.pending_import.pending_import_items[0]
                assert_equal "Wild Monkey", item.english_name
		assert_equal 'google.com', item.link
		assert_equal 'beans', item.tag_list
	end

        def test_omit_column
		file = ActionController::UploadedStringIO.new("english name,Omit\nWild Monkey,cheese")
		import_file = create_import_file(file)

		assert import_file.save 
		assert_equal 1, import_file.pending_import.pending_import_items.size

		item = import_file.pending_import.pending_import_items[0]
                assert_equal "Wild Monkey", item.english_name
	end
        
        def test_duplicate_column
		file = ActionController::UploadedStringIO.new("english name,English Name\nWild Monkey,Wild Monkey")
		import_file = create_import_file(file)

		assert !import_file.save 
                assert import_file.errors.on(:file)
		assert_equal 0, import_file.pending_import.pending_import_items.size
        end

        def test_duplicate_omit_column
		file = ActionController::UploadedStringIO.new("english name,Omit,omit\nWild Monkey,cheese,beans")
		import_file = create_import_file(file)

		assert import_file.save 
		assert_equal 1, import_file.pending_import.pending_import_items.size

		item = import_file.pending_import.pending_import_items[0]
                assert_equal "Wild Monkey", item.english_name
	end

	private
	def create_import_file(file)
		import_file = ImportFile.new(:file => file)

		import_file.user = users(:joe)

		pending_import = PendingImport.new
		pending_import.user = users(:joe)
		pending_import.filename = 'test.csv'
		pending_import.save!

		import_file.pending_import = pending_import

		return import_file
	end
end
