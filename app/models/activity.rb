class Activity < ActiveRecord::Base
  attr_accessible

  belongs_to  :user

  named_scope :photo, :conditions => ["type IN ('SightingPhotoActivity', 'TripPhotoActivity', 'UserLocationPhotoActivity')"]

  named_scope :non_photo, :conditions => ["type = 'SightingActivity'"]

  def description
    if(@description.nil?) then
      @description = data && YAML::load(data)
      unless @description.is_a? Hash then
        @description = Hash.new
      end
    end
    @description
  end

  def before_validation
    self.data = description.to_yaml 
  end
end
