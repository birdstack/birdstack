# Be sure to restart your web server when you modify this file.

# We're all international
$KCODE = 'UTF8'
require 'jcode'

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'raspell'
  config.gem 'nokogiri', :lib => 'nokogiri'
  config.gem 'image_science', :lib => 'image_science'
  config.gem 'RubyInline', :lib => 'inline'
  config.gem 'thoughtbot-shoulda', :lib => 'shoulda', :source => "http://gems.github.com"
  config.gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com'
  config.gem 'raganwald-andand', :lib => 'andand', :source => "http://gems.github.com"
  config.gem 'jviney-acts_as_taggable_on_steroids', :lib => 'acts_as_taggable', :source => "http://gems.github.com"
  config.gem 'collectiveidea-awesome_nested_set', :lib => 'awesome_nested_set', :source => "http://gems.github.com"
  config.gem 'rack'
  config.gem 'delayed_job'

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_resource, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store
  #config.action_controller.session_store = :cookie_store

  config.action_controller.session = {
    :session_key => '_birdstack_session',
  }

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer, :password_recovery_code_observer, :comment_observer, :message_observer, :message_reference_observer, :friend_request_observer, :activity_observer

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc

  # Turn on timezone support (for user display stuf)
  config.time_zone = 'UTC'

  # See Rails::Configuration for more options
end

ActionController::Base.cache_store = :file_store, "#{RAILS_ROOT}/cache"

# Add new inflection rules using the following format
# (all these examples are active by default):
ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )

	inflect.irregular 'genus', 'genera'
	inflect.irregular 'RememberMeCookie', 'RememberMeCookies'
end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below

REMEMBER_ME_COOKIE_NAME = :_birdstack_remember_me
REMEMBER_ME_COOKIE_DURATION = 1.month
EMAIL_NOTIFICATION_FROM = '"Birdstack" <do_not_reply@birdstack.com>'
EMAIL_NOTIFICATION_PREFIX = '[Birdstack]'
ACCOUNT_ACTIVIATION_TIMEOUT = 1.week
PASSWORD_RECOVERY_CODE_DURATION = 1.week
TEMP_SAVED_SEARCH_TIMEOUT = 1.month
UNKNOWN_TAXON_ERROR = "Oops!  We couldn't find the taxon you requested."

ExceptionNotifier.exception_recipients = %w(example@example.com)
CONTACT_FORM_RECIPIENTS = %w(example@example.com)

ENV['ASPELL_CONF'] = "dict-dir #{RAILS_ROOT}/data; master birdstack.rws"
