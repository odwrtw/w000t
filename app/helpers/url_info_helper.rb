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

  def url_type_link(url_info)
    icon_class = 'external-link'
    return icon_class unless url_info
    case url_info.type
    when 'github'
      icon_class = 'github'
    when 'youtube'
      icon_class = 'youtube-play'
    when 'image'
      icon_class = 'image'
    when 'pdf'
      icon_class = 'file-pdf-o'
    when 'soundcloud'
      icon_class = 'soundcloud'
    when 'stack_overflow'
      icon_class = 'stack-overflow'
    when 'hackernews'
      icon_class = 'hacker-news'
    end
    content_tag :i, '', class: "fa fa-#{icon_class}"
  end
end
