# W000t helper
module W000tHelper
  def redirect_path(w000t)
    '/' + w000t.short_url
  end

  def printable_long_url(w000t)
    truncate(w000t.long_url, length: 80)
  end
end
