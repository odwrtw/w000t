# W000t helper
module W000tHelper
  # Returns a link to the w000te with the good icon
  def get_w000t_link(w000t)
    type = w000t.url_info.type
    if type.eql? 'youtube'
      link_to w000t_click_path(w000t.short_url),
              remote: :true,
              class: "btn btn-default #{type_class(w000t.url_info.type)}" do
        url_type_link(w000t.url_info)
      end
    else
      link_to w000t_redirect_path(w000t.short_url),
              method: :get,
              class: "btn btn-default #{type_class(w000t.url_info.type)}" do
        url_type_link(w000t.url_info)
      end
    end
  end
end
