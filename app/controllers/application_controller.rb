# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery

  # Email notifications when bad things happen
  include ExceptionNotifiable

  # We need to redefine rescue_action_in_public to handle InvalidAuthenticityToken errors differently
  def rescue_action_in_public(exception)
    case exception
    when *self.class.exceptions_to_treat_as_404
      render_404
    when ActionController::InvalidAuthenticityToken
      render_cookie_error
    else          
      render_500

      deliverer = self.class.exception_data
      data = case deliverer
             when nil then {}
             when Symbol then send(deliverer)
             when Proc then deliverer.call(self)
             end

      ExceptionNotifier.deliver_exception_notification(exception, self, request, data)
    end
  end

  def render_cookie_error
    respond_to do |type|
      type.html { render :template => 'application/cookie_error' }
      type.all  { render :nothing => true }
    end
  end

  def render_404
    respond_to do |type|
      type.html { render :template => 'application/404', :status => 404 }
      type.all  { render :nothing => true, :status => 404 }
    end
  end

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # Redirect helpers
  include Birdstack::Redirect

  # Log GC stats, if enabled (first before filter)
  before_filter :before_log_gc_stats
  
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :check_blocked_user

  before_filter :login_required

  # Global cache sweeper
  cache_sweeper :sighting_sweeper
  cache_sweeper :search_sweeper

  # Time zone support
  before_filter :set_time_zone
 
  # Log GC stats, if enabled (last after filter)
  after_filter :after_log_gc_stats

  def before_log_gc_stats
    return if (ENV['RUBY_GC_STATS'].nil? or ENV['RUBY_GC_STATS'] != '1')

    GC.log "***"
    GC.log "Request starting: " + request.url
    GC.log "***"
  end

  def after_log_gc_stats
    return if (ENV['RUBY_GC_STATS'].nil? or ENV['RUBY_GC_STATS'] != '1')

    GC.log "***"
    GC.log "Request completed: " + request.url
    GC.log "GC collections: " + GC.collections.to_s
    GC.log "GC time (us): " + GC.time.to_s
    GC.log "Bytes allocated since last GC run: " + GC.growth.to_s
    GC.log "Bytes allocated since last request: " + GC.allocated_size.to_s
    GC.log "Number of allocations since last request: " + GC.num_allocations.to_s
    GC.log "Live objects: " + ObjectSpace.live_objects.to_s
    GC.log "Total allocated objects since interpreter start: " + ObjectSpace.allocated_objects.to_s
    GC.dump
    GC.log "***"

    GC.clear_stats
  end

  def set_time_zone
    Time.zone = current_user.time_zone if logged_in?
  end

  # implies login_required
  def supporting_member_required
    unless(login_required && current_user.supporting_member) then
      flash[:warning] = "The page you are trying to access requires a supporting membership"
      session[:redirect_to] = request.request_uri
      redirect_to :controller => 'main', :action => 'supporting-members'
    end
  end
end
