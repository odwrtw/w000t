require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  setup do
    User.all.destroy
    W000t.all.destroy

    @user = FactoryGirl.create(:user)
    @w000t = FactoryGirl.create(:w000t)
    @authentication_token = FactoryGirl.create(:authentication_token)
  end

  test "should be redirected if not logged" do
    sign_in @user
    get :dashboard
    assert_redirected_to root_path
  end

  test "should get dashboard as admin" do
    @user.admin = 1
    @user.save!
    sign_in @user
    get :dashboard
    assert_response :success
  end

  test "should be redirected if not admin" do
    sign_in @user
    get :dashboard
    assert_redirected_to root_path
  end

end
