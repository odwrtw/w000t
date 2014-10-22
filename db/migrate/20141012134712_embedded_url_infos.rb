class EmbeddedUrlInfos < Mongoid::Migration
  def self.up
    say_with_time('Removing old url_infos collection') do
      db = Mongoid::Sessions.default
      old_url_infos = db[:url_infos]
      old_url_infos.drop()
    end

    say_with_time('Adding embedded relations and creating task') do
      W000t.all.each do |w|
        w.build_url_info(url: w.long_url)
        w.url_info.save
        w.url_info.create_task
        say " -> #{w.short_url} done"
      end
    end
  end

  def self.down
  end
end
