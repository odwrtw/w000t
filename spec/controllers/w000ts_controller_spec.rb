require 'spec_helper'

# w000tsController tests
describe W000tsController do
  before do
    User.delete_all
    W000t.delete_all
    AuthenticationToken.destroy_all
    FakeWeb.clean_registry
    Sidekiq::Worker.clear_all
    Geocoder.configure(lookup: :test)

    @user = FactoryGirl.create(:user)
    @admin_user = FactoryGirl.create(
      :user, pseudo: 'admin', email: 'email@admin.com', admin: true
    )
    @w000t = FactoryGirl.create(:w000t)
    @authentication_token = FactoryGirl.create(
      :authentication_token, user: @user
    )
    @admin_authentication_token = FactoryGirl.create(
      :authentication_token, user: @admin_user
    )
    freegeoip_json = <<-JSON
{
    "ip": "8.8.8.8",
    "country_code": "US",
    "country_name": "United States",
    "region_code": "CA",
    "region_name": "California",
    "city": "Mountain View",
    "zip_code": "94035",
    "time_zone": "America/Los_Angeles",
    "latitude": 37.386,
    "longitude": -122.0838,
    "metro_code": 807
}
JSON
    Geocoder::Lookup::Test.set_default_stub(
      [
        {
          'latitude'     => 40.7143528,
          'longitude'    => -74.0059731,
          'address'      => 'New York, NY, USA',
          'state'        => 'New York',
          'state_code'   => 'NY',
          'country'      => 'United States',
          'country_code' => 'US'
        }
      ]
    )

    FakeWeb.register_uri(:any, %r/freegeoip/, body: freegeoip_json)
  end

  before(:each) do
    request.env['HTTP_REFERER'] = 'where_i_came_from'
  end

  it 'should create a w000t as json' do
    expect do
      post :create, w000t: { long_url: 'http://google.fr' },
                    user_id: @user.id, format: :json
    end.to change { W000t.count }.by(1)

    assert_response :success
  end

  it 'should create a w000t as json with no http prefix' do
    expect do
      post :create, w000t: { long_url: 'google.fr' },
                    user_id: @user.id, format: :json
    end.to change { W000t.count }.by(1)

    assert_response :success
  end

  it 'should create a w000t as js' do
    expect do
      post :create, w000t: { long_url: 'http://google.fr' },
                    user_id: @user.id, format: :js
    end.to change { W000t.count }.by(1)

    assert_response :success
  end

  it 'should create a w000t with a status as json' do
    url = 'http://google.fr'
    expect do
      post :create, w000t: { long_url: url, status: 'private' },
                    user_id: @user.id, format: :json
    end.to change { W000t.count }.by(1)

    assert_response :success
    w = W000t.find_by('url_info.url' => url)
    assert_equal w.status, :private, 'w000t status should be private'
  end

  it 'should not create a w000t with a wrong status as json' do
    expect do
      post :create, w000t: { long_url: 'http://google.fr', status: 'yo' },
                    user_id: @user.id, format: :json
    end.to change { W000t.count }.by(0)

    assert_response 422 # unprocessable entity
  end

  it 'should create an existing w000t as json' do
    expect do
      post :create, w000t: { long_url: @w000t.long_url },
                    user_id: @user.id, format: :json
    end.to change { W000t.count }.by(0)

    assert_response :success
  end

  it 'should return the same w000t as given' do
    expect do
      post :create,
           w000t: { long_url: @w000t.full_shortened_url(request.base_url) },
           format: :json
    end.to change { W000t.count }.by(0)

    assert_response :success
  end

  it 'should create an existing w000t as js' do
    expect do
      post :create, w000t: { long_url: @w000t.long_url },
                    user_id: @user.id, format: :js
    end.to change { W000t.count }.by(0)
    assert_response :success
  end

  it 'should get show on public w000t' do
    get :show, short_url: @w000t.short_url
    assert_response :success
  end

  it 'should not get show on private w000t' do
    @w000t_private = FactoryGirl.create(
      :w000t, long_url: 'test.com/t.jpg', status: :private, user: @user
    )
    get :show, short_url: @w000t_private.short_url
    expect(response).to redirect_to(root_path)
  end

  it 'should get show on private w000t as owner' do
    sign_in @user
    @w000t_private = FactoryGirl.create(
      :w000t, long_url: 'test.com/t.jpg', status: :private, user: @user
    )
    get :show, short_url: @w000t_private.short_url
    assert_response :success
  end

  it 'should get show on public user w000t' do
    @w000t_public = FactoryGirl.create(
      :w000t, long_url: 'test.com/t.jpg', status: :public, user: @user
    )
    get :show, short_url: @w000t_public.short_url
    assert_response :success
  end

  it 'should get new' do
    get :new
    assert_response :success
  end

  it 'should destroy as a logged in user' do
    sign_in @user
    @user_w000t = W000t.create!(
      user: @user,
      long_url: 'http://destroy_logged_in.com'
    )
    expect do
      post :destroy, short_url: @user_w000t.short_url
    end.to change { W000t.count }.by(-1)
    expect(response).to redirect_to('where_i_came_from')
    assert_equal 'W000t was successfully destroyed', flash[:notice]
  end

  it 'should destroy with a user token as json' do
    @w000t.user = @user
    @w000t.save
    request.headers['X-Auth-Token'] = @authentication_token.token
    expect do
      post :destroy, short_url: @w000t.short_url, format: :json
    end.to change { W000t.count }.by(-1)
    assert_response :success
  end

  it 'should destroy with an admin token as json' do
    @w000t.user = @user
    @w000t.save
    request.headers['X-Auth-Token'] = @admin_authentication_token.token
    expect do
      post :destroy, short_url: @w000t.short_url, format: :json
    end.to change { W000t.count }.by(-1)
    assert_response :success
  end

  it 'should destroy as an admin user' do
    sign_in @admin_user
    @user_w000t = W000t.create!(
      user: @user,
      long_url: 'http://destroy_logged_in.com'
    )
    expect do
      post :destroy, short_url: @user_w000t.short_url
    end.to change { W000t.count }.by(-1)
    expect(response).to redirect_to('where_i_came_from')
    assert_equal 'W000t was successfully destroyed', flash[:notice]
  end

  it 'should not destroy as anonymous user' do
    expect do
      post :destroy, short_url: @w000t.short_url
    end.to change { W000t.count }.by(0)
    assert_redirected_to new_user_session_url
  end

  it 'should not destroy as the wrong user' do
    joe = FactoryGirl.create(:user, pseudo: 'Joe', email: 'joe@plop.com')
    w000t_by_joe = FactoryGirl.create(
      :w000t,
      long_url: 'http://superjoe.com',
      user: joe
    )
    sign_in @user
    expect do
      post :destroy, short_url: w000t_by_joe.short_url, format: :json
    end.to change { W000t.count }.by(0)
    assert_equal 'You can not delete this w000t, only the owner can',
                 flash[:alert]
  end

  it 'should update as a logged in user' do
    sign_in @user
    @user_w000t = FactoryGirl.create(
      :w000t,
      user: @user,
      long_url: 'http://updated_logged_in.com'
    )
    patch :update, short_url: @user_w000t.short_url, format: :js,
                   w000t: { tags: 'test,      yo' }
    assert_response :success
    @w = W000t.find(@user_w000t.id)
    assert_equal %w(test yo), @w.tags_array
    assert_equal 'test,yo', @w.tags
  end

  it 'should not update as anonymous user' do
    patch :update, short_url: @w000t, format: :js, w000t: { tags: 'test, yo' }
    assert_response 401
  end

  it 'should not update as the wrong user' do
    joe = FactoryGirl.create(:user, pseudo: 'Joe', email: 'joe@plop.com')
    w000t_by_joe = FactoryGirl.create(
      :w000t,
      long_url: 'http://superjoe.com',
      user: joe
    )
    sign_in @user
    patch :update, short_url: w000t_by_joe.short_url, format: :js,
                   w000t: { tags: 'test, yo' }
    assert_equal 'You can not update this w000t, only the owner can',
                 flash[:alert]
  end

  it 'should create a w000t with a token as param' do
    expect do
      post :create, w000t: { long_url: 'google.fr' },
                    token: @authentication_token.token,
                    format: :json
    end.to change { W000t.count }.by(1)
    assert_response :success
    created_w000t = W000t.find_by('url_info.url' => 'http://google.fr')
    expect(created_w000t).not_to be_nil
    assert_equal created_w000t.user_id, @user.id
  end

  it 'should create a w000t with a token as header as json' do
    request.headers['X-Auth-Token'] = @authentication_token.token
    expect do
      post :create, w000t: { long_url: 'google.fr', status: 'private' },
                    format: :json
    end.to change { W000t.count }.by(1)
    assert_response :created
    created_w000t = W000t.find_by('url_info.url' => 'http://google.fr')
    expect(created_w000t).not_to be_nil
    assert_equal created_w000t.user_id, @user.id
  end

  it 'should get user w000t list' do
    sign_in @user
    get :owner_list
    assert_response :success
  end

  it 'should get user w000t list filtered by type' do
    sign_in @user
    TypableUrl::TYPES.each do |type|
      get :owner_list, type: type.to_s
      assert_response :success
    end
  end

  it 'should get user w000t list with a filter error' do
    sign_in @user
    get :owner_list, type: 'some shit'
    assert_redirected_to w000ts_me_url
    assert_equal 'Invalid filter', flash[:alert]
  end

  it 'should get 404 on public wall of fake user' do
    get :user_wall, user_pseudo: 'bazooka'
    assert_response 404
  end

  it 'should be redirected' do
    request.headers['REMOTE_ADDR'] = '8.8.8.8'

    before_redirect = @w000t.number_of_click
    clicks_before_redirect = W000t.find(@w000t.id).clicks.count
    get :redirect, short_url: @w000t.short_url
    # We should check the info from db because the inc method runs an update on
    # the w000t directly in db
    after_redirect = W000t.find(@w000t.id).number_of_click
    clicks_after_redirect = W000t.find(@w000t.id).clicks.count

    assert_equal before_redirect + 1, after_redirect, 'Wrong number of click'
    assert_redirected_to @w000t.long_url
    # We should have created a click object embedded within the w000t
    assert_equal clicks_before_redirect + 1,
                 clicks_after_redirect,
                 'Wrong number of click objects'

    click = W000t.find(@w000t.id).clicks.last
    expect(click.ip).to eq '8.8.8.8'
    expect(click.address).to eq 'New York, NY, USA'
    expect(click.coordinates).to eq [-122.0838, 37.386]
  end

  it 'should get a 404 http code for a fake link' do
    get :redirect, short_url: 'null'
    assert_response 404
  end

  it 'should be have one more click' do
    request.headers['REMOTE_ADDR'] = '8.8.8.8'
    before_redirect = @w000t.number_of_click
    get :click, format: :js, short_url: @w000t.short_url
    after_redirect = W000t.find(@w000t.id).number_of_click
    assert_equal before_redirect + 1, after_redirect, 'Wrong number of click'
    assert_response :success
  end
end
