require 'spec_helper'

describe 'W000ts' do
  # it 'should hash a long url with no user' do
  #   w000t_test = FactoryGirl.create(:w000t)
  #   assert_equal '64a1f36deb', w000t_test.short_url

    # user.send_password_reset
    # last_token = user.password_reset_token
    # user.send_password_reset
    # user.password_reset_token.should_not eq(last_token)
  # end
  include ActionView::Helpers::TextHelper
  include CarrierWave::Test::Matchers
  require 'digest/sha1'

  # Run before each test
  before do
    # Known values
    @long_url = 'http://www.google.com'
    @short_url_without_user = '738ddf35b3'
    @short_url_with_user = '00e7901bd2' # Pseudo greg
  end

  it 'should hash a long url with no user' do
    @w000t = FactoryGirl.create(:w000t, long_url: @long_url)
    assert_equal @short_url_without_user, @w000t.short_url
  end

  it 'should hash a long url with user greg' do
    @greg = FactoryGirl.create(:user, pseudo: 'greg', email: 'greg@odwrtw.com')
    @w000t = FactoryGirl.build(:w000t, long_url: @long_url)
    @w000t.user = @greg
    @w000t.save
    assert_equal @short_url_with_user, @w000t.short_url
  end

  it 'should not have an empty long_url' do
    @w000t = W000t.new
    assert @w000t.url_info.invalid?, 'An empty w000t should not be valid'
    assert @w000t.url_info.errors[:url].any?
  end

  it 'should not have an invalid long_url' do
    @w000t = W000t.new(long_url: 'http://')
    assert @w000t.url_info.invalid?, 'An empty w000t should not be valid'
    assert @w000t.url_info.errors[:url].any?
  end

  it 'should be valid with long_url' do
    @w000t = W000t.new(long_url: @long_url)
    assert @w000t.valid?, 'A w000t with a long_url should be valid'
  end

  it 'should be valid with upload_image' do
    @w000t = W000t.new(
      upload_image: File.open("#{Rails.root}/app/assets/images/w000t.jpg")
    )
    assert @w000t.valid?, 'A w000t with a upload_image should be valid'
  end

  it 'should be valid whitout http prefix and should have http prefix' do
    @w000t = W000t.create(long_url: 'google.com')
    assert @w000t.url_info.valid?, 'w000t without http prefix is invalid'
    assert @w000t.url_info.url =~ /^http/,
           'w000t without http prefix does not have http prefix'
  end

  it 'shoud create a life checker task when creating a new w000t' do
    expect{
      @w000t = W000t.create(long_url: @long_url)
    }.to change{UrlLifeChecker.jobs.size}.by(1)
  end

  it 'shoud have a valid status' do
    W000t::STATUS.each do |s|
      @w000t = FactoryGirl.build(:w000t, long_url: @long_url, status: s)
      assert @w000t.valid?, "w000t should be valid with this staus : #{s}"
    end
  end

  it 'shoud not be valid with a wrong status' do
    %i( test yo mama ).each do |s|
      @w000t = FactoryGirl.build(:w000t, long_url: @long_url, status: s)
      assert @w000t.invalid?, "invalid w000t status #{s}"
    end
  end

  it 'shoud create a w000t with a upload_image' do
    @w000t = W000t.new(
      upload_image: File.open("#{Rails.root}/app/assets/images/w000t.jpg")
    )

    assert @w000t.url_info.valid?, 'w000t without http prefix is invalid'
    assert_equal @w000t.url_info.internal_status,
                 :to_upload,
                 'w000t with upload_image should have an internal_status'
    assert_equal @w000t.url_info.url,
                 nil, 'w000t with upload_image should have a nil url'

    @w000t.url_info.cloud_image.remove!
  end
end
