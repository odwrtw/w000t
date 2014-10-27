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

  def type_icon(type)
    return 'external-link' unless TYPE_ICON_CLASS.key?(type.to_sym)
    TYPE_ICON_CLASS[type.to_sym]
  end

  def type_class(type)
    return unless type
    return '' unless TYPE_ICON_CLASS.key?(type.to_sym)
    "type-#{type}"
  end

  def url_type_link(url_info)
    icon_class = 'external-link'
    icon_class = type_icon(url_info.type) if url_info && url_info.type
    content_tag :i, '', class: "fa fa-#{icon_class}"
  end

  def url_type_span(type)
    icon_class = type_icon(type)
    content_tag :span do
      name = type.to_s.capitalize.gsub('_', ' ')
      icon = content_tag :i, '', class: "fa fa-#{icon_class}"
      icon + ' ' + name
    end
  end
end
