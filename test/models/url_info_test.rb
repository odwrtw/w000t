require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

# UrlInfo test
class UrlInfoTest < ActiveSupport::TestCase
  setup do
    # Clean all fakewebs
    FakeWeb.clean_registry
    initiate_fake_web
  end

  # fake_web_list = {
  FAKE_WEB_LIST = {
    image_ok: { url: 'http://test.com/ok.jpg', content_length: 12_000 },
    image_bis: { url: 'http://test.com/ok_bis.jpg', content_length: 12_000 },
    image_404: {
      url: 'http://test.com/404.jpg',
      content_length: 12_000,
      status: ['404', 'Not Found']
    },
    image_too_big: {
      url: 'http://test.com/too_big.jpg',
      content_length: 12_000_000
    },
    not_image_ok: { url: 'http://test.com/', content_length: 12_000 },
    not_image_404: {
      url: 'http://test.com/404',
      content_length: 12_000,
      status: ['404', 'Not Found']
    },
    not_image_too_big: {
      url: 'http://test.com/too_big',
      content_length: 12_000_000
    }
  }

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

  test 'shoud update http_code and content_length when creating a new w000t' do
    Sidekiq::Testing.inline! do
      @w000t_404 = W000t.create(long_url: FAKE_WEB_LIST[:image_404][:url])
      @w000t_404.reload
      assert_equal 404, @w000t_404.url_info.http_code
      assert_equal 12_000, @w000t_404.url_info.content_length

      @w000t_200 = W000t.create(long_url: FAKE_WEB_LIST[:image_ok][:url])
      @w000t_200.reload
      assert_equal 200, @w000t_200.url_info.http_code
      assert_equal 12_000, @w000t_200.url_info.content_length
    end
  end

  test 'shoud download when image is valid' do
    Sidekiq::Testing.inline! do
      @w000t = W000t.create(long_url: FAKE_WEB_LIST[:image_ok][:url])
    end
    @w000t.reload

    assert_equal 12_000, @w000t.url_info.content_length
    assert_not_equal @w000t.url_info.url, @w000t.url_info.cloud_image_urls[:url]
    assert_not nil, @w000t.url_info.cloud_image_urls[:thumb]
  end

  test 'shoud not download when not a valid image' do
    Sidekiq::Testing.inline! do
      @w000t = W000t.create(long_url: FAKE_WEB_LIST[:not_image_ok][:url])
    end
    @w000t.reload

    assert_equal nil, @w000t.url_info.cloud_image_urls,
                 'Cloud image is not nil but not an image'
  end

  test 'shoud not download when image too big' do
    Sidekiq::Testing.inline! do
      @w000t = W000t.create(long_url: FAKE_WEB_LIST[:image_too_big][:url])
    end
    @w000t.reload

    assert_equal nil, @w000t.url_info.cloud_image_urls,
                 'Cloud image is not nil but too big'
  end

  test 'shoud not download when image is not 200' do
    Sidekiq::Testing.inline! do
      @w000t = W000t.create(long_url: FAKE_WEB_LIST[:image_404][:url])
    end
    @w000t.reload

    assert_equal nil, @w000t.url_info.cloud_image_urls,
                 'Cloud image is not nil but 301'
  end

  test 'shoud get default url when cloud_image not yet set' do
    @w000t = W000t.create(long_url: FAKE_WEB_LIST[:image_ok][:url])
    @w000t.reload

    assert_equal @w000t.url_info.cloud_image.url, @w000t.url_info.url,
                 'Bad image default url'
  end

  test 'shoud get good url' do
    Sidekiq::Testing.inline! do
      @w000t_cloudy = W000t.create(long_url: FAKE_WEB_LIST[:image_ok][:url])
    end
    @w000t = W000t.create(long_url: FAKE_WEB_LIST[:image_bis][:url])
    @w000t.reload

    assert_equal @w000t_cloudy.url_info.cloud_image.thumb.url,
                 @w000t_cloudy.url_info.w000t_cloud_image_url(:thumb),
                 'Bad image default url'
    assert_equal @w000t_cloudy.url_info.cloud_image.url,
                 @w000t_cloudy.url_info.w000t_cloud_image_url(:url),
                 'Bad image default url'
    assert_equal @w000t.url_info.cloud_image.url,
                 @w000t.url_info.w000t_cloud_image_url(:url),
                 'Bad image default url'
    assert_equal @w000t.url_info.cloud_image.url,
                 @w000t.url_info.w000t_cloud_image_url(:thumb),
                 'Bad image default url'
  end

  private

  def initiate_fake_web
    FAKE_WEB_LIST.each do |_, info|
      url = info[:url]
      content_length = info[:content_length]
      status = info[:status] || ['200', 'All ok']
      FakeWeb.register_uri(
        :any,
        url,
        content_length: content_length,
        status: status
      )
    end
  end
end
