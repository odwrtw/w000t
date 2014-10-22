require 'test_helper'

# UrlInfo test
class UrlInfoTest < ActiveSupport::TestCase
  setup do
    W000t.all.destroy
  end

  test 'type sould be found' do
    types_and_urls = {
      youtube: 'https://www.youtube.com/watch?v=LoJtfpDWpmY',
      image: 'http://test/yo.jpg',
      pdf: 'http://test/yo.pdf',
      soundcloud: 'https://soundcloud.com/l-c-a-w/andreas-moe-ocean',
      github: 'https://github.com/gregdel',
      stack_overflow: 'http://stackoverflow.com/questions/948135',
      hackernews: 'https://news.ycombinator.com/'
    }
    types_and_urls.each do |type, url|
      @w000t = FactoryGirl.create(:w000t, long_url: url)
      assert_equal type.to_s, @w000t.url_info.type
    end
  end

  test 'type should not be found' do
    urls = [
      'https://test.com',
      'https://yomma.fr/youtube'
    ]
    urls.each do |url|
      @w000t = FactoryGirl.build(:w000t, long_url: url)
      @w000t.save
      assert_nil @w000t.url_info.type
    end
  end

  test 'type should not be updated' do
    @w000t = FactoryGirl.create(:w000t, long_url: 'http://test.com/test.jpg')
    @w000t.url_info.type = 'test'
    assert_equal 'test', @w000t.url_info.type
  end

  test 'type should be updated if forced' do
    @w000t = FactoryGirl.create(:w000t, long_url: 'http://test.com/test.jpg')
    @w000t.url_info.type = 'test'
    @w000t.url_info.find_type(true)
    @w000t.url_info.save
    assert_equal 'image', @w000t.url_info.type
  end
end
