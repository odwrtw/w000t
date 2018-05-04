class EmbeddedUrlInfos < Mongoid::Migration
  def self.up
    say_with_time('Removing old url_infos collection') do
      db = Mongoid::Clients.default
      old_url_infos = db[:url_infos]
      old_url_infos.drop()
    end

    say_with_time('Adding embedded relations') do
      W000t.all.each do |w|
        w.build_url_info(url: w.long_url)
        w.url_info.save
        say " -> #{w.short_url} done"
      end
    end
    say_with_time('Removing long_url from w000ts') do
      W000t.all.update_all('$unset' => { 'long_url' => 1 })
    end
  end

  def self.down
  end
end
