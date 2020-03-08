require 'rails_helper'
require 'spec_helper'

describe 'w000t requests', type: :request do
  before do
    User.delete_all
    W000t.delete_all
    AuthenticationToken.destroy_all
    Sidekiq::Worker.clear_all

    @user = FactoryBot.create(:user)
    @admin_user = FactoryBot.create(
      :user, pseudo: 'admin', email: 'email@admin.com', admin: true
    )
    @w000t = FactoryBot.create(:w000t)
    @authentication_token = FactoryBot.create(
      :authentication_token, user: @user
    )
    @admin_authentication_token = FactoryBot.create(
      :authentication_token, user: @admin_user
    )
  end

  def sign_in(user)
    login_as(user, scope: :user)
  end

  it 'should return the user created w000t as json' do
    headers = {
      'ACCEPT'       => 'application/json',     # This is what Rails 4 accepts
      'X-Auth-Token' => @authentication_token.token,
      'HTTP_REFERER' => 'where_i_came_from'
    }
    post '/w000ts', params: {
      w000t: {
        long_url: 'google.fr', status: 'private', tags: 'test,yo'
      }
    }, headers: headers

    expect(response.media_type).to eq('application/json')
    expect(response).to have_http_status(:created)

    %w( id w000t url type tags status number_of_click created_at ).each do |key|
      expect(response.body).to have_json_path(key)
    end
    %w( user url_info ).each do |key|
      expect(response.body).not_to have_json_path(key)
    end

    assert_equal 'http://google.fr', json_response['url']
    assert_equal 'private', json_response['status']
    assert_nil json_response['type']
    assert_equal 0, json_response['number_of_click']
    assert_equal json_response['tags'], %w( test yo )
  end

  it 'should return the anonymously created w000t as json' do
    headers = {
      'ACCEPT'       => 'application/json',     # This is what Rails 4 accepts
      'HTTP_REFERER' => 'where_i_came_from'
    }
    post '/w000ts', params: {
      w000t: {
        long_url: 'google.fr'
      }
    }, headers: headers
    assert_response :created

    json_expected_keys %w( id w000t url type number_of_click created_at )
    json_unexpected_keys %w( tags status user url_info )

    assert_equal 'http://google.fr', json_response['url']
    assert_nil json_response['type']
    assert_equal 0, json_response['number_of_click']
  end

  it 'should get w000t as non admin user as json' do
    sign_in @user
    @w000t.user = @admin_user
    @w000t.save
    get "/w000ts/#{@w000t.short_url}", as: :json
    assert_response :success
    json_expected_keys %w( id w000t url type )
    json_unexpected_keys %w(
      tags status number_of_click created_at user url_info
    )
  end

  it 'should get w000t as an admin user as json' do
    sign_in @admin_user
    @w000t.user = @user
    @w000t.save
    get "/w000ts/#{@w000t.short_url}", as: :json
    assert_response :success
    json_expected_keys %w(
      id w000t url type tags status number_of_click created_at user url_info
    )
  end

  it 'should get w000t with an admin token as json' do
    @w000t.user = @user
    @w000t.save
    headers = {
      'ACCEPT'       => 'application/json',
      'X-Auth-Token' => @admin_authentication_token.token,
      'HTTP_REFERER' => 'where_i_came_from'
    }
    get "/w000ts/#{@w000t.short_url}.json", params: headers
    assert_response :success
    json_expected_keys %w(
      id w000t url type
    )
  end

  # Create two w000t, only one tagged with 'test'
  # Search for tag:'test', expect 1 only one result
  it 'should filter by tags' do
    sign_in @user
    @w000t_no_tag = FactoryBot.create(
      :w000t, long_url: 'yo.com', user: @user
    )
    @w000t_tag_test = FactoryBot.create(
      :w000t, long_url: 'test.com', tags: 'test  ', user: @user
    )
    assert_equal 2, @user.w000ts.count
    get '/w000ts/me'
    assert_response :success
    assert_select 'tbody', children: { count: 2, only: { tag: 'tr' } }
    assert_select 'td', attributes: { class: 'w000t-tags' },
                    children: { count: 1, only: { tag: 'span' } }
  end

  # Create two typed w000t with the same tag
  # 1 - type: pdf - tag: test
  # 1 - type: image - tag: test
  # Search for type:'image' and tag:'test', expect 1 only one result
  it 'should filter by tags and type' do
    sign_in @user
    @w000t_image_no_tag = FactoryBot.create(
      :w000t, long_url: 'yo.com/t.pdf', tags: 'test', user: @user
    )
    @w000t_image_tag = FactoryBot.create(
      :w000t, long_url: 'test.com/t.jpg', tags: 'test', user: @user
    )
    assert_equal 2, @user.w000ts.count
    get '/w000ts/me?tags=test&type=image'
    assert_response :success
    assert_select 'tbody', children: { count: 2, only: { tag: 'tr' } }
    assert_select 'td', attributes: { class: 'w000t-tags' },
                    children: { count: 1, only: { tag: 'span' } }
  end

  it 'should get index as a non admin user' do
    sign_in @user
    get '/'
    assert_response :success
    assert_select '.navbar-collapse li', 9
  end

  it 'should get index as an admin user' do
    sign_in @admin_user
    get '/'
    assert_response :success
    assert_select '.navbar-collapse li', 10
  end

  it 'should get index as anonymous user' do
    get '/'
    assert_response :success
    assert_select 'li', 4
  end

  it 'should get public wall of a user as anonymous user' do
    @w000t_public = FactoryBot.create(
      :w000t, long_url: 'yo.com/t.gif', user: @user
    )
    @w000t_private = FactoryBot.create(
      :w000t, long_url: 'test.com/t.jpg', status: :private, user: @user
    )
    get "/users/#{@user.pseudo}/wall"
    assert_response :success
    assert_select 'figure', @user.w000ts.where(status: :public).count
  end
end
