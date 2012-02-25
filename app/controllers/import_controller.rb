class ImportController < ApplicationController
	def index
		@pending_imports = current_user.pending_imports
	end

	def upload
		@import_file = ImportFile.new(params[:import_file])

		return unless request.post?

		@import_file.user = current_user

		pending_import = PendingImport.new
		pending_import.user = current_user
		pending_import.save!

		@import_file.pending_import = pending_import

		unless @import_file.save then
			pending_import.destroy
			return
		end

		pending_import.filename = @import_file.filename
		pending_import.description = @import_file.description
		pending_import.ebird_exclude = @import_file.ebird_exclude
		pending_import.save!

		redirect_to :action => 'validate', :id => pending_import.id
	end

	def delete
		@pending_import = current_user.pending_imports.find_by_id(params[:id])

		redirect_to :action => 'index'
		
		return unless @pending_import and request.post?

		PendingImport.transaction do
			@pending_import.destroy

			flash[:notice] = 'Deleted Pending Import ' + @pending_import.filename
		end
	end

	def delete_pending_import_item
		@pending_import = current_user.pending_imports.find_by_id(params[:id])
		unless @pending_import then
			redirect_to :action => 'index'
			return
		end

		@pending_import_item = @pending_import.pending_import_items.find_by_id(params[:pending_import_item])
		
		redirect_to :action => 'pending', :id => @pending_import.id

		return unless @pending_import_item and request.post?

		@pending_import_item.destroy

		flash[:notice] = 'Deleted Pending Import Item on line ' + @pending_import_item.line.to_s
	end

	def valid
		@pending_import = current_user.pending_imports.find_by_id(params[:id])
		unless @pending_import then
			redirect_to :action => 'index'
			return
		end

		# Validate items in chunks of 50 valid items
		@pending_import_items = []
		PendingImport.transaction do
			@pending_import.pending_import_items.find(:all, :order => 'line', :conditions => {:validated => nil}).each do |pending_import_item|
				pending_import_item.validated = pending_import_item.pre_realization ? true : false
				# Set the english name to be what we have in the db.
				# Clears up cases where they may have Cooper<funny apostrophe>s Hawk
				pending_import_item.english_name = pending_import_item.sighting.species.english_name if pending_import_item.validated
				pending_import_item.save
				@pending_import_items << pending_import_item if pending_import_item.validated
				break if @pending_import_items.size >= 50
			end
		end

		# We got a page request, but it didn't have any items to save (so we can skip the processing below)
		# and there are no items left to display, so we might as well redirect to the pending page
		if !params[:pending_import_items] and @pending_import_items.size == 0 then
			redirect_to :action => 'pending', :id => @pending_import.id
			return
		end

		# Return unless we have a post
		return unless request.post?
		
		params[:pending_import_items] ||= []
	
		success_counter = 0
                last_saved_sighting = nil
		PendingImport.transaction do
			params[:pending_import_items].each do |k,v|
				pending_import_item = @pending_import.pending_import_items.find(:first, :conditions => ['id = ?', k])
				next unless pending_import_item
				if v.to_i == 1 then
					# If there were problems, we need to mark it as invalid
					unless pending_import_item.realize(true) then
						pending_import_item.validated = false
						pending_import_item.save!
					else
						success_counter += 1
                                                last_saved_sighting = pending_import_item.sighting
						pending_import_item.destroy
					end
				else
					pending_import_item.validated = false
					pending_import_item.save!
				end
			end
		end

		if success_counter > 0 then
			flash.now[:notice] = 'Successfully imported ' + success_counter.to_s + ' records'
			# And now we need to resave one of these things so that the cache gets updated.
			# It wasn't updated before because we called .realize(true) which marked it
			# as a part of a batch operation.  It doesn't matter which one we resave because
			# the sweeper will take care of clearing things for all affected records.
                        last_saved_sighting.batch = false
			last_saved_sighting.save!
		end

		# If there's nothing left, redirect
		unless @pending_import_items.size > 0
			redirect_to :action => 'pending', :id => @pending_import.id 
			# Now that we're on a redirect, we need to change to plain flash instead of flash.now
			flash[:notice] = flash.now[:notice]
			return
		end
	end

	def validate
		@pending_import = current_user.pending_imports.find_by_id(params[:id])
		unless @pending_import
			redirect_to :action => 'index'
			return
		end
	end

	def revalidate
		@pending_import = current_user.pending_imports.find_by_id(params[:id])
		unless @pending_import and request.post?
			redirect_to :action => 'index'
			return
		end

		@pending_import.pending_import_items.update_all('validated = NULL');

		redirect_to :action => 'valid', :id => @pending_import.id
	end

	def pending
		@pending_import = current_user.pending_imports.find_by_id(params[:id])
		unless @pending_import then
			redirect_to :action => 'index'
			return
		end

		@pending_import_items = @pending_import.pending_import_items.paginate(:page => params[:page], :order => 'line')

		respond_to do |format|
			format.html
			format.js do
				render :update do |page|
					page.replace_html 'pending', :partial => 'pending'
				end
			end
		end
	end
end
