ActiveRecord::Base.class_eval do
  def self.validates_http_url(*attrs)
    configuration = {
      :message => I18n.translate('activerecord.errors.messages')[:invalid], 
      :on => :save
    }

    configuration.update(attrs.pop) if attrs.last.is_a?(Hash)

    validates_each(attrs, configuration) do |record, attr, value|
      unless value.nil? or value == '' then
        # If they forgot the protocol, add HTTP for them
        unless value.include? ':' then
          value = 'http://' + value
          record.write_attribute(attr, value)
        end

        begin
          uri = URI.parse(value)
          if (uri.class != URI::HTTP) and (uri.class != URI::HTTPS)
            record.errors.add(attr, 'Only HTTP(S) protocol addresses can be used')
          end
        rescue URI::InvalidURIError
          record.errors.add(attr, 'does not have a valid format')
        end
      end
    end
  end
end
