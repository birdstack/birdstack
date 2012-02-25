require File.dirname(__FILE__) + '/../../test_helper'
require 'action_view/test_case'
class ApplicationHelperTest < ActionView::TestCase

  def test_strip_tags
    want_fragment = 'The webternets [http://google.com]'
    got_fragment = birdstack_strip_tags '<a href="http://google.com">The webternets</a>'
    assert_equal want_fragment, got_fragment
  end

  def test_enclose_in_usercontent_div
    want_fragment = '<div class="usercontent"><p>Sometimes spaghetti just doesn\'t work out...</p></div>'
    got_fragment = birdstack_sanitize 'Sometimes spaghetti just doesn\'t work out...'
    assert_dom_equal want_fragment, got_fragment
  end

  def test_replace_newlines
    # paragraphs
    want_fragment = "<div class=\"usercontent\"><p>cool!</p>\n\n<p>fab!</p></div>"
    got_fragment = birdstack_sanitize "cool!\r\n\r\n\r\n\r\nfab!"
    assert_dom_equal want_fragment, got_fragment

    want_fragment = "<div class=\"usercontent\"><p>cool!</p>\n\n<p>fab!</p></div>"
    got_fragment = birdstack_sanitize "cool!\n\n\n\nfab!"
    assert_dom_equal want_fragment, got_fragment

    # line breaks
    want_fragment = "<div class=\"usercontent\"><p>cool!\n<br>fab!</p></div>"
    got_fragment = birdstack_sanitize "cool!\nfab!"
    assert_dom_equal want_fragment, got_fragment

    want_fragment = "<div class=\"usercontent\"><p>cool!\n<br>fab!</p></div>"
    got_fragment = birdstack_sanitize "cool!\r\nfab!"
    assert_dom_equal want_fragment, got_fragment

    # multiple paragraphs
    want_fragment = "<div class=\"usercontent\"><p>cool!</p>\n\n<p>fab!</p>\n\n<p>gnarly!</p></div>"
    got_fragment = birdstack_sanitize "cool!\n\n\n\nfab!\n\n\n\ngnarly!"
    assert_dom_equal want_fragment, got_fragment

    want_fragment = "<div class=\"usercontent\"><p>cool!</p>\n\n<p>fab!</p>\n\n<p>gnarly!</p></div>"
    got_fragment = birdstack_sanitize "cool!\r\n\r\n\r\n\r\nfab!\r\n\r\n\r\n\r\ngnarly!"
    assert_dom_equal want_fragment, got_fragment

    # multiple line breaks
    want_fragment = "<div class=\"usercontent\"><p>cool!\n<br>fab!\n<br>gnarly!</p></div>"
    got_fragment = birdstack_sanitize "cool!\nfab!\ngnarly!"
    assert_dom_equal want_fragment, got_fragment

    want_fragment = "<div class=\"usercontent\"><p>cool!\n<br>fab!\n<br>gnarly!</p></div>"
    got_fragment = birdstack_sanitize "cool!\r\nfab!\r\ngnarly!"
    assert_dom_equal want_fragment, got_fragment

    # both
    want_fragment = "<div class=\"usercontent\"><p>cool!\n<br>fab!</p>\n\n<p>gnarly!</p></div>"
    got_fragment = birdstack_sanitize "cool!\nfab!\n\ngnarly!"
    assert_dom_equal want_fragment, got_fragment

    want_fragment = "<div class=\"usercontent\"><p>cool!\n<br>fab!</p>\n\n<p>gnarly!</p></div>"
    got_fragment = birdstack_sanitize "cool!\r\nfab!\r\n\r\ngnarly!"
    assert_dom_equal want_fragment, got_fragment
  end

  def test_links_add_nofollow
    want_fragment = '<div class="usercontent"><p><a rel="nofollow" href="http://google.com">Google</a></p></div>'
    got_fragment = birdstack_sanitize '<a href="http://google.com">Google</a>'
    assert_dom_equal want_fragment, got_fragment
  end

  def test_works_for_whitelist
    want_fragment = '<div class="usercontent"><p><b>awesome</b></p></div>'
    got_fragment = birdstack_sanitize '<b>awesome</b>'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p><i>awesome</i></p></div>'
    got_fragment = birdstack_sanitize '<i>awesome</i>'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p><em>awesome</em></p></div>'
    got_fragment = birdstack_sanitize '<em>awesome</em>'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p><strong>awesome</strong></p></div>'
    got_fragment = birdstack_sanitize '<strong>awesome</strong>'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p><u>awesome</u></p></div>'
    got_fragment = birdstack_sanitize '<u>awesome</u>'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p>awesome<br>bang!</p></div>'
    got_fragment = birdstack_sanitize 'awesome<br>bang!'
    assert_dom_equal want_fragment, got_fragment

    # the \n shouldn't really be required.  I guess assert_dom_equal isn't so great?
    want_fragment = "<div class=\"usercontent\"><p>awesome</p>\n<p>more awesome</p></div>"
    got_fragment = birdstack_sanitize 'awesome<p>more awesome</p>'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = "<div class=\"usercontent\"><p></p>\n<blockquote>awesome</blockquote></div>"
    got_fragment = birdstack_sanitize '<blockquote>awesome</blockquote>'
    # assert_dom_equal gets confused here.  Hopefully we can fix it later
    assert_equal want_fragment, got_fragment
  end

  def test_not_in_whitelist
    want_fragment = '<div class="usercontent"><p>awesome</p></div>'
    got_fragment = birdstack_sanitize '<marquee>awesome</marquee>'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p>awesome</p></div>'
    got_fragment = birdstack_sanitize '<blink>awesome</blink>'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p><img></p></div>'
    got_fragment = birdstack_sanitize '<img foobar="cool">'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p><a rel="nofollow">awesome</a></p></div>'
    got_fragment = birdstack_sanitize '<a hrerf="awesomebot">awesome</a>'
    assert_dom_equal want_fragment, got_fragment

    # h1 is in the mail Rails whitelist, but not in ours
    want_fragment = '<div class="usercontent"><p>awesome</p></div>'
    got_fragment = birdstack_sanitize '<h1>awesome</hi>'
    assert_dom_equal want_fragment, got_fragment
  end

  def test_links_cannot_be_relative
    want_fragment = '<div class="usercontent"><p>Check out my sweet worbsite <a rel="nofollow" href="http://blog.afoolishmanifesto.com">it is very cool</a></p></div>'
    got_fragment = birdstack_sanitize 'Check out my sweet worbsite <a href="blog.afoolishmanifesto.com">it is very cool</a>'
    assert_dom_equal want_fragment, got_fragment
  end

  def test_whitelist_attributes
    want_fragment = '<div class="usercontent"><p><img height="25" src="http://icanhascheezburger.com/cat.jpg"></p></div>'
    got_fragment = birdstack_sanitize '<img src="http://icanhascheezburger.com/cat.jpg" height="25">'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p><img width="23" src="http://icanhascheezburger.com/cat.jpg"></p></div>'
    got_fragment = birdstack_sanitize '<img width="23" src="http://icanhascheezburger.com/cat.jpg">'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p><img alt="cat" src="http://icanhascheezburger.com/cat.jpg"></p></div>'
    got_fragment = birdstack_sanitize '<img alt="cat" src="http://icanhascheezburger.com/cat.jpg">'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p><img title="cat" src="http://icanhascheezburger.com/cat.jpg"></p></div>'
    got_fragment = birdstack_sanitize '<img title="cat" src="http://icanhascheezburger.com/cat.jpg">'
    assert_dom_equal want_fragment, got_fragment
  end

  def test_images_cannot_be_relative
    want_fragment = '<div class="usercontent"><p>Check out my sweet cat <img src="http://icanhascheezburger.files.wordpress.com/2009/01/funny-pictures-cats-are-scared-of-hairless-cat.jpg"></p></div>'
    got_fragment = birdstack_sanitize 'Check out my sweet cat <img src="icanhascheezburger.files.wordpress.com/2009/01/funny-pictures-cats-are-scared-of-hairless-cat.jpg">'
    assert_dom_equal want_fragment, got_fragment
  end

  def test_dwim
    want_fragment = '<div class="usercontent"><p>fjord &gt; frew</p></div>'
    got_fragment = birdstack_sanitize 'fjord > frew'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p>frew &amp; catherine</p></div>'
    got_fragment = birdstack_sanitize 'frew & catherine'
    assert_dom_equal want_fragment, got_fragment

    want_fragment = '<div class="usercontent"><p>mice &lt; katz</p></div>'
    got_fragment = birdstack_sanitize 'mice < katz'
    assert_dom_equal want_fragment, got_fragment
  end

  def test_security
    want_fragment = '<div class="usercontent"><p>Check out my sweet worbsite <a rel="nofollow">it is very cool</a></p></div>'
    got_fragment = birdstack_sanitize 'Check out my sweet worbsite <a href="javascript:haXXed()">it is very cool</a>'
    assert_dom_equal want_fragment, got_fragment
  end
end
