# This monkeypatch lets us cache pages including the URL parameters.  It requires some
# extra Apache setup before it will work

# Here's the Apache magic:
# RewriteCond %{QUERY_STRING} .
# RewriteCond %{DOCUMENT_ROOT}/cache%{REQUEST_URI}_/%{QUERY_STRING} -f
# RewriteRule .* %{DOCUMENT_ROOT}/cache%{REQUEST_URI}_/%{QUERY_STRING} [L]
# 
# RewriteCond %{QUERY_STRING} !.
# RewriteCond %{DOCUMENT_ROOT}/cache%{REQUEST_URI} -f
# RewriteRule .* %{DOCUMENT_ROOT}/cache%{REQUEST_URI} [L]

unless RAILS_GEM_VERSION == '2.3.4' then
  raise "Don't upgrade rails without making sure this monkeypatch still works!"
end

module ActionController #:nodoc:
  module Caching
    module Pages
      def cache_page(content = nil, options = nil)
        return unless perform_caching && caching_allowed

        path = case options
          when Hash
            url_for(options.merge(:only_path => true, :skip_relative_url_root => true, :format => params[:format]))
          when String
            options
          else
            # We need the underscore to differentiate between these two cases:
            # /foo?bar=baz
            # /foo/bar=baz
            # Unlikely, but better to be certain.  Of course, using the underscore
            # means we're open to problems if there's ever two controllers whose
            # names differ only by a trailing underscore.  I would have used a
            # more exotic char, but Apache didn't like any of those.
            #
            # Also note that if the request comes in with a trailing ?, we need
            # to remove it.  Apache won't see a query string if ? is the last
            # char in the URL, so our dir logic doesn't make sense there,
            # and if there is nothing after the ?, then the filename we tell
            # Rails to use for the cache is actually a directory name,
            # which will cause an error.
            URI.escape(request.request_uri).sub(/\?$/, '').sub('?', '_/')
        end

        # Don't write out excessively long URLs.  Can result in ENAMETOOLONG errors
        if(path.length > 500) then
          return
        end

        self.class.cache_page(content || response.body, path)
      end
    end
  end
end

ActionController::Base.page_cache_extension = ''
ActionController::Base.page_cache_directory = 'public/cache'
