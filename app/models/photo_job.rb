class PhotoJob < Struct.new(:photo_class, :image_id)
  def perform
    photo_class.constantize.do_post_process(self.image_id)
  end
end
