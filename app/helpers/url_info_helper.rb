# UrlInfo helper
module UrlInfoHelper
  def pretty_http_status(url_info)
    if url_info
      css_class = url_info.active? ? 'success' : 'danger'
      icon_class = url_info.active? ? 'chain' : 'chain-broken'
      content_tag :span, class: "label label-#{css_class}" do
        content_tag :i, " #{url_info.http_code}", class: "fa fa-#{icon_class}"
      end
    else
      content_tag :span, 'Not Checked', class: 'label label-default'
    end
  end

  TYPE_ICON_CLASS = {
    github: 'github',
    youtube: 'youtube-play',
    image: 'image',
    pdf: 'file-pdf-o',
    soundcloud: 'soundcloud',
    stack_overflow: 'stack-overflow',
    hackernews: 'hacker-news'
  }

  def url_type_link(url_info)
    icon_class = 'external-link'
    return icon_class unless url_info
    TYPE_ICON_CLASS.each do |type, css_class|
      next unless type.to_s == url_info.type
      icon_class = css_class
      break
    end
    content_tag :i, '', class: "fa fa-#{icon_class}"
  end
end
