# w000tsController tests
require 'test_helper'

class W000tsControllerTest < ActionController::TestCase
  setup do
    User.all.destroy
    W000t.all.destroy

    @user = FactoryGirl.create(:user)
    @w000t = FactoryGirl.create(:w000t)
  end

  test 'should create a w000t' do
    assert_difference('W000t.count') do
      post :create, w000t: { long_url: 'http://google.fr' },
                    user_id: @user.id
    end
    assert_response :success
  end

  test 'should create an existing w000t' do
    assert_difference('W000t.count', 0) do
      post :create, w000t: { long_url: @w000t.long_url },
                    user_id: @user.id
    end
    assert_response :success
  end

  test 'should get show' do
    get :show, short_url: @w000t.short_url
    assert_response :success
  end

  test 'should destroy' do
    assert_difference('W000t.count', -1) do
      post :destroy, short_url: @w000t.short_url, format: :json
    end
    assert_response :success
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
