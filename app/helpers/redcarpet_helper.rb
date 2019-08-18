module RedcarpetHelper
  def markdown(content)
    @@markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, 
    									   autolink: true,
									   	   filter_html: true,
									   	   no_links: true,
									   	   safe_links_only: true,
									   	   hard_wrap: true,
                         fenced_code_blocks: true,
									   	   space_after_headers: false)
    render = @@markdown.render(content)
    # remove the <p> tags that markdown wraps by default
    # filtered_text = Regexp.new('^<p>(.*)<\/p>$').match(render)[1].html_safe
    render.html_safe   
  end
end