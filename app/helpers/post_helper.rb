module PostHelper
  class Sanitizer < HTML::WhiteListSanitizer
    self.allowed_tags.merge(%w(img a))
  end

  def post_summary_html(post)
    if post.summary.present?
      content_tag :p, post.summary
    else
      reg = /<!--more-->/
      html_text = post_content_html(post)

      html = !((html_text =~ reg).nil?) ? html_text[0..(html_text =~ reg)-1] : html_text
      doc = Nokogiri::HTML.fragment(html)
      doc = doc.search('p').detect { |p| p.text.present? } if (html_text =~ reg).nil?
      doc.try(:to_html).try(:html_safe)
    end
  end

  def post_content_html(post)
    renderer = HTMLwithPygmentize.new(hard_wrap: true)
    options = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true
    }
    markdown = Redcarpet::Markdown.new(renderer, options)
    markdown.render( post.content ).html_safe
  end

  class HTMLwithPygmentize < Redcarpet::Render::HTML
    def block_code(code, language)
      require "pygmentize"
      Pygmentize.process(code, language)
    end
  end
end
