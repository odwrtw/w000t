# UrlInfo helper
module UrlInfoHelper
  def pretty_http_status(url_info)
    if url_info.http_code
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
    if url_info && url_info.type && TYPE_ICON_CLASS.key?(url_info.type.to_sym)
      icon_class = TYPE_ICON_CLASS[url_info.type.to_sym]
    end
    content_tag :i, '', class: "fa fa-#{icon_class}"
  end
end
