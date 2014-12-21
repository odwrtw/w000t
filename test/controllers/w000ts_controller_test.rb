require 'test_helper'

# w000tsController tests
class W000tsControllerTest < ActionController::TestCase
  setup do
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
  end

  test 'should create a w000t as json' do
    assert_difference('W000t.count') do
      post :create, w000t: { long_url: 'http://google.fr' },
                    user_id: @user.id, format: :json
    end
    assert_response :success
  end

  test 'should create a w000t as json with no http prefix' do
    assert_difference('W000t.count') do
      post :create, w000t: { long_url: 'google.fr' },
                    user_id: @user.id, format: :json
    end
    assert_response :success
  end

  test 'should create a w000t as js' do
    assert_difference('W000t.count') do
      post :create, w000t: { long_url: 'http://google.fr' },
                    user_id: @user.id, format: :js
    end
    assert_response :success
  end

  test 'should create a w000t with a status as json' do
    url = 'http://google.fr'
    assert_difference('W000t.count') do
      post :create, w000t: { long_url: url, status: 'private' },
                    user_id: @user.id, format: :json
    end
    assert_response :success
    w = W000t.find_by('url_info.url' => url)
    assert_equal w.status, :private, 'w000t status should be private'
  end

  test 'should not create a w000t with a wrong status as json' do
    assert_difference('W000t.count', 0) do
      post :create, w000t: { long_url: 'http://google.fr', status: 'yo' },
                    user_id: @user.id, format: :json
    end
    assert_response 422 # unprocessable entity
  end

  test 'should create an existing w000t as json' do
    assert_difference('W000t.count', 0) do
      post :create, w000t: { long_url: @w000t.long_url },
                    user_id: @user.id, format: :json
    end
    assert_response :success
  end

  test 'should return the same w000t as given' do
    assert_difference('W000t.count', 0) do
      post :create,
           w000t: { long_url: @w000t.full_shortened_url(request.base_url) },
           format: :json
    end
    assert_response :success
  end

  test 'should create an existing w000t as js' do
    assert_difference('W000t.count', 0) do
      post :create, w000t: { long_url: @w000t.long_url },
                    user_id: @user.id, format: :js
    end
    assert_response :success
  end

  test 'should get show' do
    get :show, short_url: @w000t.short_url
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should destroy as a logged in user' do
    sign_in @user
    @user_w000t = W000t.create!(
      user: @user,
      long_url: 'http://destroy_logged_in.com'
    )
    assert_difference('W000t.count', -1) do
      post :destroy, short_url: @user_w000t.short_url
    end
    assert_redirected_to 'previous_page'
    assert_equal 'W000t was successfully destroyed', flash[:notice]
  end

  test 'should destroy with a user token as json' do
    @w000t.user = @user
    @w000t.save
    request.headers['X-Token'] = @authentication_token.token
    assert_difference('W000t.count', -1) do
      post :destroy, short_url: @w000t.short_url, format: :json
    end
    assert_response :success
  end

  test 'should destroy with an admin token as json' do
    @w000t.user = @user
    @w000t.save
    request.headers['X-Token'] = @admin_authentication_token.token
    assert_difference('W000t.count', -1) do
      post :destroy, short_url: @w000t.short_url, format: :json
    end
    assert_response :success
  end

  test 'should destroy as an admin user' do
    sign_in @admin_user
    @user_w000t = W000t.create!(
      user: @user,
      long_url: 'http://destroy_logged_in.com'
    )
    assert_difference('W000t.count', -1) do
      post :destroy, short_url: @user_w000t.short_url
    end
    assert_redirected_to 'previous_page'
    assert_equal 'W000t was successfully destroyed', flash[:notice]
  end

  test 'should not destroy as anonymous user' do
    assert_difference('W000t.count', 0) do
      post :destroy, short_url: @w000t.short_url
    end
    assert_redirected_to new_user_session_url
  end

  test 'should not destroy as the wrong user' do
    joe = FactoryGirl.create(:user, pseudo: 'Joe', email: 'joe@plop.com')
    w000t_by_joe = FactoryGirl.create(
      :w000t,
      long_url: 'http://superjoe.com',
      user: joe
    )
    sign_in @user
    assert_difference('W000t.count', 0) do
      post :destroy, short_url: w000t_by_joe.short_url, format: :json
    end
    assert_equal 'You can not delete this w000t, only the owner can',
                 flash[:alert]
  end

  test 'should update as a logged in user' do
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

  test 'should not update as anonymous user' do
    patch :update, short_url: @w000t, format: :js, w000t: { tags: 'test, yo' }
    assert_response 401
  end

  test 'should not update as the wrong user' do
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

  test 'should create a w000t with a token as param' do
    assert_difference('W000t.count') do
      post :create, w000t: { long_url: 'google.fr' },
                    token: @authentication_token.token,
                    format: :json
    end
    assert_response :success
    created_w000t = W000t.find_by('url_info.url' => 'http://google.fr')
    assert_not_nil created_w000t
    assert_equal created_w000t.user_id, @user.id
  end

  test 'should create a w000t with a token as header as json' do
    request.headers['X-Token'] = @authentication_token.token
    assert_difference('W000t.count') do
      post :create, w000t: { long_url: 'google.fr', status: 'private' },
                    format: :json
    end
    assert_response :created
    created_w000t = W000t.find_by('url_info.url' => 'http://google.fr')
    assert_not_nil created_w000t
    assert_equal created_w000t.user_id, @user.id
  end

  test 'should return the user created w000t as json' do
    request.headers['X-Token'] = @authentication_token.token
    post :create, w000t: {
      long_url: 'google.fr', status: 'private', tags: 'test,yo'
    },
                  format: :json
    assert_response :created
    json_expected_keys %w(
      id w000t url type tags status number_of_click created_at
    )

    assert_equal 'http://google.fr', json_response['url']
    assert_equal 'private', json_response['status']
    assert_equal nil, json_response['type']
    assert_equal 0, json_response['number_of_click']
    assert_equal json_response['tags'], %w( test yo )
  end

  test 'should return the anonymously created w000t as json' do
    post :create, w000t: { long_url: 'google.fr' }, format: :json
    assert_response :created

    json_expected_keys %w( id w000t url type number_of_click created_at )
    json_unexpected_keys %w( tags status )

    assert_equal 'http://google.fr', json_response['url']
    assert_equal nil, json_response['type']
    assert_equal 0, json_response['number_of_click']
  end

  test 'should get w000t as non admin user as json' do
    sign_in @user
    @w000t.user = @admin_user
    @w000t.save
    get :show, short_url: @w000t.short_url, format: :json
    assert_response :success
    json_expected_keys %w( id w000t url type )
    json_unexpected_keys %w( tags status number_of_click created_at )
  end

  test 'should get w000t as an admin user as json' do
    sign_in @admin_user
    @w000t.user = @user
    @w000t.save
    get :show, short_url: @w000t.short_url, format: :json
    assert_response :success
    json_expected_keys %w(
      id w000t url type tags status number_of_click created_at
    )
  end

  test 'should get w000t with an admin token as json' do
    @w000t.user = @user
    @w000t.save
    request.headers['X-Token'] = @admin_authentication_token.token
    get :show, short_url: @w000t.short_url, format: :json
    assert_response :success
    json_expected_keys %w(
      id w000t url type tags status number_of_click created_at
    )
  end

  test 'should get user index' do
    sign_in @user
    get :my_index
    assert_response :success
  end

  test 'should get user index filtered by type' do
    sign_in @user
    TypableUrl::TYPES.each do |type|
      get :my_index, type: type.to_s
      assert_response :success
    end
  end

  # Create two w000t, only one tagged with 'test'
  # Search for tag:'test', expect 1 only one result
  test 'should filter by tags' do
    sign_in @user
    @w000t_no_tag = FactoryGirl.create(
      :w000t, long_url: 'yo.com', user: @user
    )
    @w000t_tag_test = FactoryGirl.create(
      :w000t, long_url: 'test.com', tags: 'test  ', user: @user
    )
    assert_equal 2, @user.w000ts.count
    get :my_index, tags: 'test'
    assert_response :success
    assert_tag :tbody, children: { count: 2, only: { tag: 'tr' } }
    assert_tag :td, attributes: { class: 'w000t-tags' },
                    children: { count: 1, only: { tag: 'span' } }
  end

  # Create two typed w000t with the same tag
  # 1 - type: pdf - tag: test
  # 1 - type: image - tag: test
  # Search for type:'image' and tag:'test', expect 1 only one result
  test 'should filter by tags and type' do
    sign_in @user
    @w000t_image_no_tag = FactoryGirl.create(
      :w000t, long_url: 'yo.com/t.pdf', tags: 'test', user: @user
    )
    @w000t_image_tag = FactoryGirl.create(
      :w000t, long_url: 'test.com/t.jpg', tags: 'test', user: @user
    )
    assert_equal 2, @user.w000ts.count
    get :my_index, tags: 'test', type: 'image'
    assert_response :success
    assert_tag :tbody, children: { count: 2, only: { tag: 'tr' } }
    assert_tag :td, attributes: { class: 'w000t-tags' },
                    children: { count: 1, only: { tag: 'span' } }
  end

  test 'should get user index with a filter error' do
    sign_in @user
    get :my_index, type: 'some shit'
    assert_redirected_to w000ts_me_url
    assert_equal 'Invalid filter', flash[:alert]
  end

  test 'should get public wall of a user as anonymous user' do
    @w000t_public = FactoryGirl.create(
      :w000t, long_url: 'yo.com/t.gif', user: @user
    )
    @w000t_private = FactoryGirl.create(
      :w000t, long_url: 'test.com/t.jpg', status: :private, user: @user
    )
    get :image_index, user_pseudo: @user.pseudo
    assert_response :success
    assert_select 'figure', @user.w000ts.where(status: :public).count
  end

  test 'should get 404 on public wall of fake user' do
    get :image_index, user_pseudo: 'bazooka'
    assert_response 404
  end

  test 'should get index as a non admin user' do
    sign_in @user
    get :index
    assert_response :success
    assert_select 'li', 6
  end

  test 'should get index as an admin user' do
    sign_in @admin_user
    get :index
    assert_response :success
    assert_select 'li', 7
  end

  test 'should get index as anonymous user' do
    get :index
    assert_response :success
    assert_select 'li', 3
  end

  test 'should be redirected' do
    before_redirect = @w000t.number_of_click
    get :redirect, short_url: @w000t.short_url
    # We should check the info from db because the inc method runs an update on
    # the w000t directly in db
    after_redirect = W000t.find(@w000t.id).number_of_click
    assert_equal before_redirect + 1, after_redirect, 'Wrong number of click'
    assert_redirected_to @w000t.long_url
  end

  test 'should get a 404 http code for a fake link' do
    get :redirect, short_url: 'null'
    assert_response 404
  end

  test 'should be have one more click' do
    before_redirect = @w000t.number_of_click
    get :click, format: :js,  short_url: @w000t.short_url
    after_redirect = W000t.find(@w000t.id).number_of_click
    assert_equal before_redirect + 1, after_redirect, 'Wrong number of click'
    assert_response :success
  end
end
