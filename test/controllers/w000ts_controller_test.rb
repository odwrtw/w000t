require 'test_helper'

# w000tsController tests
class W000tsControllerTest < ActionController::TestCase
  setup do
    User.all.destroy
    W000t.all.destroy

    @user = FactoryGirl.create(:user)
    @w000t = FactoryGirl.create(:w000t)
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
      post :destroy, short_url: @user_w000t.short_url, format: :json
    end
    assert_response :success
  end

  test 'should not destroy as anonymous user' do
    assert_difference('W000t.count', 0) do
      post :destroy, short_url: @w000t.short_url, format: :json
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
  end

  test 'should get index' do
    get :index
    assert_response :success
  end

  test 'should be redirected' do
    get :redirect, short_url: @w000t.short_url
    assert_redirected_to @w000t.long_url
  end
end
