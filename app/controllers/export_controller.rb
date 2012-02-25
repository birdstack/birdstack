class ExportController < ApplicationController
	def index
    if export_started? then
      @export_started = current_user.export_started
    end
    if !current_user.export.original_filename.nil? then
      @export = current_user.export
    end
	end

  def export_update
    if !export_started? && !current_user.export.original_filename.nil? then
      render :text => '<script type="text/javascript">location.reload()</script>'
    else
      render :text => ''
    end
  end

  def create
		unless request.post? then
      redirect_to :action => 'index'
      return
    end

    if export_started? then
      flash[:warning] = 'Export is already in progress'
    else
      u = current_user
      u.export_started = Time.now
      u.save!
      Delayed::Job.enqueue ExportJob.new(current_user.id)
      flash[:info] = 'Export has started'
    end

    redirect_to :action => 'index'
  end

	def download
		export = current_user.export
		
		if export.original_filename.nil? then
			redirect_to :action => 'index'
			return
		end

    send_file export.path,
      :type => export.content_type,
      :x_sendfile => (defined? ENABLE_XSENDFILE) && ENABLE_XSENDFILE
	end

  private

  def export_started?
    return current_user.export_started.andand > (Time.now - 1.hour)
  end
end
