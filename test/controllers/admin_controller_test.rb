require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

# Admin controller tests
class AdminControllerTest < ActionController::TestCase
  setup do
    User.all.destroy
    W000t.all.destroy
    Sidekiq::Worker.clear_all

    @user = FactoryGirl.create(:user)
    @admin_user = FactoryGirl.create(
      :user,
      pseudo: 'admin',
      email: 'email@admin.com',
      admin: true
    )
    @w000t = FactoryGirl.create(:w000t, long_url: 'http://google.com')
    @w000t_es = FactoryGirl.create(:w000t, long_url: 'http://google.es')
    @authentication_token = FactoryGirl.create(:authentication_token)
  end

  test 'should be redirected if not logged' do
    sign_in @user
    get :dashboard
    assert_redirected_to root_path
  end

  test 'should get dashboard as admin' do
    sign_in @admin_user
    get :dashboard
    assert_response :success
  end

  test 'should be redirected if not admin' do
    sign_in @user
    get :dashboard
    assert_redirected_to root_path
  end

  test 'should update all the w000ts as json' do
    sign_in @admin_user
    assert_difference 'UrlLifeChecker.jobs.size', W000t.all.count do
      post :check_all_w000ts, format: :json
    end
    assert_response :success
  end

  test 'should check one url as json' do
    sign_in @admin_user
    assert_difference 'UrlLifeChecker.jobs.size' do
      post :check_url, admin: { long_url: 'http://google.com' },
                       format: :json
    end
    assert_response :success
  end

  test 'should not create task to check url if none given' do
    sign_in @admin_user
    assert_raise ActionController::ParameterMissing do
      post :check_url, format: :json
    end
    assert_difference 'UrlLifeChecker.jobs.size', 0 do
      post :check_url, admin: { url: 'fake argument' },
                       format: :json
    end
  end
end
