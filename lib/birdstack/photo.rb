module Birdstack
  module Photo
    class << self
      def included base #:nodoc:
        base.extend ClassMethods

        base.has_attached_file :photo,
          :styles => {:full => "570", :thumb => "150"},
          :processors => [:imagescience],
          :path => Proc.new {|a| base.photo_path(a.instance.private)},
          :url => Proc.new {|a| base.photo_url(a.instance.private)}

        base.send(:default_scope, :conditions => {:processing => false})

        base.belongs_to	:user

        base.validates_attachment_content_type :photo, :content_type => /jpe?g|gif|png/i

        base.validates_attachment_size :photo, :less_than => 10.megabytes
        base.validates_attachment_presence :photo

        base.validates_presence_of :title
        base.validates_presence_of :license

        base.named_scope :public, :conditions => {:private => 0}

        base.validate :within_photo_upload_limit

        base.attr_accessible :photo, :title, :description, :license

        base.before_post_process :skip_post_processing_on_upload
        base.before_create :mark_for_processing
        base.before_create :recalculate_path
        base.after_create :submit_post_process_job
        base.after_create :add_photo_size
        base.before_destroy :subtract_photo_size
        base.after_save :move_photos_if_needed
      end
    end

    def publicize!(user = nil)
      if @publicized and @publicized_for != user then
        raise "Attempted to republicize photo #{self.class.name}:#{self.id.to_s} for #{user ? user.login : 'nil'} when already publicized for #{@publicized_for ? @publicized_for.login : @publicized_for}"
      end

      return self if @publicized

      if self.user == user then
        # Do nothing
      elsif self.private then
        raise "Attempted to publicize private photo #{self.class.name}:#{self.id.to_s}"
      else
        # Scrub our private status
        self.private = nil
      end

      @publicized = true
      @publicized_for = user

      self.readonly!
      self.freeze

      return self
    end

    # after_save
    def move_photos_if_needed
      if(self.private_changed?) then
        old_location = Paperclip::Interpolations.interpolate(self.class.photo_base_path(self.private_was), self.photo, :original)
        new_location = Paperclip::Interpolations.interpolate(self.class.photo_base_path(self.private), self.photo, :original)
        FileUtils.makedirs(File.dirname(new_location))
        FileUtils.mv(old_location, new_location, :force => true)
      end
    end

    # validate
    def within_photo_upload_limit
      if(self.new_record?) then
        if(self.user.num_photos >= self.user.photo_upload_limit) then
          errors.add(:file, "exceeded your total photo upload limit of #{self.user.photo_upload_limit} photos")
        end
      else
        if(self.user.num_photos > self.user.photo_upload_limit) then
          errors.add(:file, "exceeded your total photo upload limit of #{self.user.photo_upload_limit} photos")
        end
      end
    end

    # after_create
    def add_photo_size
      u = self.user
      # Just in case something goes crazy
      # TODO maybe we should send a (backgrounded) administrative notification?
      if(u.num_photos < 0) then
        u.num_photos = 0
      end
      u.num_photos += 1
      u.save!
    end

    # before_destroy
    def subtract_photo_size
      u = self.user
      u.num_photos -= 1
      # Just in case something goes crazy
      if(u.num_photos < 0) then
        u.num_photos = 0
      end
      u.save!
    end

    # before_create
    # When an object is created, it doesn't have access to the parent to determine
    # if the photo should be stored privately.  After creation, that information is
    # available.  So, we re-run the path Proc.
    def recalculate_path
      self.photo.instance_variable_set('@path', self.class.photo_path(self.private))
    end

    # after_create
    def submit_post_process_job
      Delayed::Job.enqueue PhotoJob.new(self.class.name, self.id)
    end

    # before_create
    def mark_for_processing
      self.processing = true
    end

    # before_post_process
    def skip_post_processing_on_upload
      if(self.new_record?) then
        return false
      end
    end

    module ClassMethods
      def photo_base_path(private)
        ":rails_root/user_data/#{private ? 'private' : 'public'}/:class/:attachment/:id_partition"
      end

      def photo_path(private)
        photo_base_path(private) + "/:style/:filename"
      end

      def photo_url(private)
          if(private) then
            "/#{self.name.underscore}/private_photo/:id?style=:style"
          else
            "/user_data/:class/:attachment/:id_partition/:style/:filename"
          end
      end

      def do_post_process(id)
        p = with_exclusive_scope { self.find(id) }
        begin
          p.photo.reprocess!
          p.processing = false
          p.save!
        rescue Exception => e
          logger.warn "Exception while processing photo id #{p.id} of type #{p.class.name}: " + e
          p.destroy
        end
      end

      def processing_status_for_user(ids, user)
        status = Hash.new
        ids.each do |id|
          sp = with_exclusive_scope { self.find_by_id(id) }
          if(sp.nil?) then
            status[id] = :failure
          elsif(sp.user != user) then
            status[id] = :failure
          elsif(sp.processing) then
            status[id] = :processing
          else
            status[id] = :success
          end
        end

        return status
      end
    end
  end
end
