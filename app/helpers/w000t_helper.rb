# W000t helper
module W000tHelper
  # Returns a link to the w000te with the good icon
  def get_w000t_link(w000t)
    type = w000t.url_info_type
    if type.eql? 'youtube'
      link_to w000t_click_path(w000t.short_url),
              remote: :true,
              class: "btn btn-default #{type_class(type)}" do
        url_type_link(w000t.url_info)
      end
    else
      link_to w000t_redirect_path(w000t.short_url),
              method: :get,
              class: "btn btn-default #{type_class(type)}" do
        url_type_link(w000t.url_info)
      end
    end
  end

  def pretty_tags(w000t)
    return content_tag :span, 'No tags',
                       class: 'label label-default' if w000t.tags_array.empty?
    w000t.tags_array.each.map do |tag|
      content_tag :span, tag, class: 'label label-primary'
    end.join(' ').html_safe
  end
end
