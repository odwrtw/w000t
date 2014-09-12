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
end
