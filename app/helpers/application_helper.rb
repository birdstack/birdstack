# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def birdstack_sanitize(s)
    Birdstack::sanitize(sanitize(s, :tags => %w(br p b i em strong u blockquote a img), :attributes => %w(title alt href src height width)))
  end

  def birdstack_strip_tags(s)
    Birdstack::strip_tags(s)
  end

  def add_to_head(stuff)
    @add_to_head ||= []
    @add_to_head << stuff
  end

  def add_to_head_string
    @add_to_head ||= []
    @add_to_head.join("\n")
  end

  def add_to_body_params(params)
    @body_params ||= Hash.new
    params.each_key do |k|
      key = k.to_s
      # If the parameter starts with "on," it must be related to javascript, so we'll concatenate them
      if key =~ /^on/i then
        @body_params[key] = (@body_params[key].blank? ? '' : (@body_params[key] + '; ')) + "#{params[k]};"
        @body_params[key].gsub!(/;+/, ';');
      else
        @body_params[key] = params[key]
      end
    end
  end

  def body_params_string
    @body_params ||= Hash.new
    params = []
    @body_params.each {|k,v| params << "#{k}=\"#{v}\"" }
    params.join(' ')
  end

  # Danger!
  # We load TagsHelper here to make sure we actually overwrite the tag_cloud method
  # The problem is that that tags_controller controller will automatically load any
  # module named TagsHelper.  If we don't load it here before we redefine tag_cloud,
  # then it will be loaded later, and it will get the final say on the definition of
  # tag_cloud.
  include TagsHelper
  def tag_cloud(tags, classes)
    return if tags.empty?

    max_count = tags.sort_by(&:count).last.count.to_f
    if max_count < classes.size then
      max_count = classes.size.to_f
    end

    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size)).round - 1
      index = index < 0 ? 0 : index
      yield tag, classes[index]
    end
  end
end
