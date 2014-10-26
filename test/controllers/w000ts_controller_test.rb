require 'test_helper'

# w000tsController tests
class W000tsControllerTest < ActionController::TestCase
  setup do
    User.all.destroy
    W000t.all.destroy

    request.env['HTTP_REFERER'] = 'previous_page'

    @user = FactoryGirl.create(:user)
    @admin_user = FactoryGirl.create(
      :user,
      pseudo: 'admin',
      email: 'email@admin.com',
      admin: true
    )
    @w000t = FactoryGirl.create(:w000t)
    @authentication_token = FactoryGirl.create(:authentication_token)
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
    assert_equal 'W000t was successfully destroyed.', flash[:notice]
  end

  test 'should not destroy as anonymous user' do
    assert_difference('W000t.count', 0) do
      post :destroy, short_url: @w000t.short_url
    end
    assert_redirected_to new_user_session_url
  end

  test 'should not destroy as the wrong user' do
    joe = FactoryGirl.create(:user, pseudo: 'Joe', email: 'joe@plop.com')
    w000t_by_joe = W000t.create(
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

  test 'should create a w000t with a token' do
    @authentication_token.user = @user
    @authentication_token.save
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

  test 'should get user index with a filter error' do
    sign_in @user
    get :my_index, type: 'some shit'
    assert_redirected_to w000ts_me_url
    assert_equal 'Invalid filter', flash[:alert]
  end

  test 'should get index as anonymous user' do
    get :index
    assert_response :success
    assert_select 'li', 3
  end

  test 'should get index as a non admin user' do
    sign_in @user
    get :index
    assert_response :success
    assert_select 'li', 5
  end

  test 'should get index as an admin user' do
    sign_in @admin_user
    get :index
    assert_response :success
    assert_select 'li', 6
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

  test 'should be have one more click' do
    before_redirect = @w000t.number_of_click
    get :click, format: :js,  short_url: @w000t.short_url
    after_redirect = W000t.find(@w000t.id).number_of_click
    assert_equal before_redirect + 1, after_redirect, 'Wrong number of click'
    assert_response :success
  end
end
