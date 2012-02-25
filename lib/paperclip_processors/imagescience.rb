module Paperclip
  # Handles thumbnailing images that are uploaded using imagescience
  class Imagescience < Processor
    def make
      dst = Tempfile.new(file.path)
      begin
      ImageScience.with_image(file.path) do |img|
        img.thumbnail([options[:geometry].to_i, img.width, img.height].min) do |thumb|
          thumb.save(dst.path)
        end
      end
      rescue TypeError
        raise PaperclipError, "is not a recognized format"
      rescue
        raise PaperclipError, "had errors during processing"
      end
      return dst
    end
  end
end
