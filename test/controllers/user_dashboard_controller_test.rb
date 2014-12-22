require 'test_helper'

# User dashboard controller tests
class UserDashboardControllerTest < ActionController::TestCase
  setup do
    @user_greg = FactoryGirl.create(
      :user, pseudo: 'greg', email: 'greg@w000t.me'
    )
    @user_pouulet = FactoryGirl.create(
      :user, pseudo: 'pouulet', email: 'pouulet@w000t.me'
    )
  end

  test 'should be redirected if not logged' do
    get :show, user_pseudo: 'greg'
    assert_redirected_to new_user_session_path
  end

  test 'should get user\'s dashboard' do
    sign_in @user_pouulet
    get :show, user_pseudo: @user_pouulet.pseudo
    assert_response :success
  end

  test 'should get a 404 trying to access another user\'s dashboard' do
    sign_in @user_pouulet
    get :show, user_pseudo: @user_greg.pseudo
    assert_response :not_found
  end
end
