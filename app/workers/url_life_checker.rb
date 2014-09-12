# Workers
class UrlLifeChecker
  include Sidekiq::Worker
  # sidekiq_options queue: "high"
  # sidekiq_options retry: false

  def perform(long_url)
    # Look or create a new UrlInfo object
    url = UrlInfo.find_by(url: long_url)
    url = UrlInfo.create(url: long_url) unless url

    begin
      uri = URI.parse(long_url)
      puts "======= #{uri} ========"
      begin
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.read_timeout = 10
          response = http.head(uri.path.size > 0 ? uri.path : '/')
          puts response.inspect
          puts "Response code #{response.code}"
          url.http_code = response.code
        end
      rescue => e
        puts 'Shiiiiit'
        puts e
        url.http_code = 500
      end
    rescue URI::Error => e
      puts 'Shiiiiit, bad URI'
      url.http_code = 500
    end

    url.inc(number_of_checks: 1)
    url.touch(:last_check)
    if url.save!
      puts "UrlInfo saved"
    else
      puts "Problem when saving the UrlInfo!"
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
