module Birdstack::Sanitize
  def self.birdstack_sanitize(s)
    s = self.line_breaks(s)
    doc = Nokogiri::HTML.parse(s)
    self.fix_links(doc)
    self.fix_images(doc)
    # sanitize should be included from ActionView::Helpers
    return self.wrapper(doc)
  end

  def self.strip_tags(s)
    doc = Nokogiri::HTML.parse(s)
    self.fix_links(doc)
    self.replace_links(doc)
    return doc.at('/html/body').inner_text
  end

  def self.replace_links(doc)
    doc.css('a').each do |link|
      url = link.get_attribute('href')
      link.content = "#{link.content} [#{url}]"
    end
  end

  def self.wrapper(doc)
    return '<div class="usercontent">' + doc.at('/html/body').inner_html + '</div>'
  end

  def self.line_breaks(s)
    # Drop all \r.  That way "\r\n" goes to "\n"
    s.to_s.gsub!("\r", "")

    # replacing newlines with <br> and <p> tags
    # wrapping text into paragraph
    s = "<p>" + s.gsub(/\n\n+/, "</p>\n\n<p>")
    s = s.gsub(/([^\n]\n)(?=[^\n])/, '\1<br />') + "</p>"
    return s
  end

  def self.fix_urls(doc, element_type, attribute)
    doc.css(element_type).each do |element|
      url = element.get_attribute(attribute)
      if url and !url.include?":"
        url = "http://" + url
        element.set_attribute(attribute, url)
      end
    end
  end

  def self.fix_links(doc)
    doc.css('a').each do |link|
      link.set_attribute('rel', 'nofollow')
    end
    self.fix_urls(doc, 'a', 'href')
  end

  def self.fix_images(doc)
    self.fix_urls(doc, 'img', 'src')
  end
end
