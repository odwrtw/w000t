require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

# UrlInfo test
describe 'UrlInfos' do
  before do
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

  it 'type should be found' do
    types_and_urls = {
      youtube: [
        'https://www.youtube.com/watch?v=LoJtfpDWpmY',
        'http://www.youtube.com/watch?v=LoJtfpDWpmY',
        'https://youtu.be/watch?v=LoJtfpDWpmY',
        'http://youtu.be/watch?v=LoJtfpDWpmY',
      ],
      image: [
        'http://test/yo.jpg',
      ],
      pdf: [
        'http://test/yo.pdf',
      ],
      soundcloud: [
        'https://soundcloud.com/l-c-a-w/andreas-moe-ocean',
      ],
      github: [
        'https://github.com/gregdel',
      ],
      stack_overflow: [
        'http://stackoverflow.com/questions/948135',
      ],
      hackernews: [
        'https://news.ycombinator.com/',
      ]
    }
    types_and_urls.each do |type, urls|
      urls.each do |url|
        @w000t = FactoryBot.create(:w000t, long_url: url)
        assert_equal type.to_s, @w000t.url_info.type
      end
    end
  end

  it 'type should not be found' do
    urls = [
      'https://test.com',
      'https://yomma.fr/youtube'
    ]
    urls.each do |url|
      @w000t = FactoryBot.build(:w000t, long_url: url)
      @w000t.save
      assert_nil @w000t.url_info.type
    end
  end

  it 'type should not be updated' do
    @w000t = FactoryBot.create(:w000t, long_url: 'http://test.com/test.jpg')
    @w000t.url_info.type = 'test'
    assert_equal 'test', @w000t.url_info.type
  end

  it 'type should be updated if forced' do
    @w000t = FactoryBot.create(:w000t, long_url: 'http://test.com/test.jpg')
    @w000t.url_info.type = 'test'
    @w000t.url_info.find_type(true)
    @w000t.url_info.save
    assert_equal 'image', @w000t.url_info.type
  end

  it 'should update http_code and content_length when creating a new w000t' do
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

  it 'should not download when image is valid but w000t is public' do
    Sidekiq::Testing.inline! do
      @w000t = W000t.create(
        long_url: FAKE_WEB_LIST[:image_ok][:url]
      )
    end
    @w000t.reload

    assert_nil @w000t.url_info.cloud_image_urls,
                 'Cloud image is not nil but not an image'
    assert_equal 12_000, @w000t.url_info.content_length
  end

  it 'should not download when not a valid image' do
    Sidekiq::Testing.inline! do
      @w000t = W000t.create(long_url: FAKE_WEB_LIST[:not_image_ok][:url])
    end
    @w000t.reload

    assert_nil @w000t.url_info.cloud_image_urls,
                 'Cloud image is not nil but not an image'
  end

  it 'should not download when image too big' do
    Sidekiq::Testing.inline! do
      @w000t = W000t.create(long_url: FAKE_WEB_LIST[:image_too_big][:url])
    end
    @w000t.reload

    assert_nil @w000t.url_info.cloud_image_urls,
                 'Cloud image is not nil but too big'
  end

  it 'should not download when image is not 200' do
    Sidekiq::Testing.inline! do
      @w000t = W000t.create(long_url: FAKE_WEB_LIST[:image_404][:url])
    end
    @w000t.reload

    assert_nil @w000t.url_info.cloud_image_urls,
                 'Cloud image is not nil but 301'
  end

  it 'should get default url when cloud_image not yet set' do
    @w000t = W000t.create(long_url: FAKE_WEB_LIST[:image_ok][:url])
    @w000t.reload

    assert_equal @w000t.url_info.cloud_image.url, @w000t.url_info.url,
                 'Bad image default url'
  end

  it 'should get good url' do
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

  it 'should have a valid internal_status' do
    UrlInfo::INTERNAL_STATUS.each do |s|
      @url_info = FactoryBot.build(
        :url_info, url: 'http://google.com',
                   internal_status: s
      )
      assert @url_info.valid?,
             "url_info should be valid with this status : #{s}"
    end
  end

  it 'should have a invalid internal_status' do
    %i( test yo mama ).each do |s|
      @url_info = FactoryBot.build(
        :url_info, url: 'http://google.com',
                   internal_status: s
      )
      assert @url_info.invalid?,
             "url_info should be invalid with this status : #{s}"
    end
  end

  private

  def initiate_fake_web
    FAKE_WEB_LIST.each do |_, info|
      url = info[:url]
      content_length = info[:content_length]
      status = info[:status] || ['200', 'All ok']
      stub_request(
        :any,
        url
      ).to_return(
        status: status,
        headers: {
          'Content-Length' => content_length
        }
      )
    end
  end
end
