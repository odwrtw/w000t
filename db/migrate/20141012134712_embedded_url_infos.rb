class EmbeddedUrlInfos < Mongoid::Migration
  def self.up
    say_with_time('Removing old url_infos collection') do
      db = Mongoid::Sessions.default
      old_url_infos = db[:url_infos]
      old_url_infos.drop()
    end

    say_with_time('Adding embedded relations and creating task') do
      W000t.all.each do |w|
        w.build_url_info(url: w.old_long_url)
        w.url_info.save
        w.url_info.create_task
        say " -> #{w.short_url} done"
      end
    end
    say_with_time('Removing long_url from w000ts') do
      db = Mongoid::Sessions.default

      w000ts = db[:w000ts]
      w000ts.find().update_all('$unset' => { 'long_url' => 1 })
    end
  end

  def self.down
  end
end
