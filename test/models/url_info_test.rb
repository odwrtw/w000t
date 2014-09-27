require 'test_helper'

# UrlInfo test
class UrlInfoTest < ActiveSupport::TestCase
  setup do
    UrlInfo.all.destroy
  end

  test 'type sould be found' do
    types_and_urls = {
      youtube: 'https://www.youtube.com/watch?v=LoJtfpDWpmY',
      image: 'http://test/yo.jpg',
      pdf: 'http://test/yo.pdf',
      soundcloud: 'https://soundcloud.com/l-c-a-w/andreas-moe-ocean',
      github: 'https://github.com/gregdel'
    }
    types_and_urls.each do |type, url|
      @url_info = FactoryGirl.create(:url_info, url: url)
      assert_equal type.to_s, @url_info.type
    end
  end

  test 'type should not be found' do
    urls = [
      'https://test.com',
      'https://yomma.fr/youtube'
    ]
    urls.each do |url|
      @url_info = FactoryGirl.create(:url_info, url: url)
      assert_nil @url_info.type
    end
  end

  test 'type should not be updated' do
    @url_info = FactoryGirl.create(
      :url_info,
      url: 'http://test.com/test.jpg',
      type: 'test'
    )
    assert_equal 'test', @url_info.type
  end

  test 'type should be updated if forced' do
    @url_info = FactoryGirl.create(
      :url_info,
      url: 'http://test.com/test.jpg',
      type: 'test'
    )
    @url_info.find_type(true)
    @url_info.save
    assert_equal 'image', @url_info.type
  end
end
