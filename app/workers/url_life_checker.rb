# Workers
class UrlLifeChecker
  include Sidekiq::Worker
  # sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform(long_url)
    # Look or create a new UrlInfo object
    url = UrlInfo.find_by(url: long_url)
    url = UrlInfo.create(url: long_url) unless url

    # Try to parse the URI
    begin
      uri = URI.parse(long_url)
      puts "======= #{uri} ========"
      # Try head request
      begin
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 10
        http.start do |r|
          response = r.head(uri.path.size > 0 ? uri.path : '/')
          puts "Response code #{response.code}"
          url.http_code = response.code
        end
      rescue => e
        puts "Error while head request: #{e}"
        url.http_code = 500
      end
    rescue URI::Error => e
      puts "Bad URI: #{e}"
      url.http_code = 500
    end

    # Save the url
    url.inc(number_of_checks: 1)
    url.touch(:last_check)
    if url.save!
      puts 'UrlInfo saved'
    else
      puts 'Problem when saving the UrlInfo!'
    end

    # Archive the unwanted w000ts
    if url.active?
      puts "#{long_url} is active"
      url.w000ts.each do |w|
        puts "  #{w.short_url} is active so we update"
        w.archive = 0
        w.save
      end
    else
      puts "#{long_url} is dead"
      url.w000ts.each do |w|
        puts "  #{w.short_url} is dead so we archive"
        w.archive!
      end
    end

    puts "----- / #{uri} ------"
    puts
  end
end
