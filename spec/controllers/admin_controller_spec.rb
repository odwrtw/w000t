require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

# Admin controller tests
describe AdminController do
  before do
    User.delete_all
    W000t.delete_all
    AuthenticationToken.destroy_all
    Sidekiq::Worker.clear_all

    @user = FactoryBot.create(:user)
    @admin_user = FactoryBot.create(
      :user,
      pseudo: 'admin',
      email: 'email@admin.com',
      admin: true
    )
    @w000t = FactoryBot.create(:w000t, long_url: 'http://google.com')
    @w000t_es = FactoryBot.create(:w000t, long_url: 'http://google.es')
    @authentication_token = FactoryBot.create(:authentication_token)
  end

  before(:each) do
    request.env["HTTP_REFERER"] = 'where_i_came_from'
  end

  it 'should be redirected if not logged' do
    get :dashboard
    assert_redirected_to new_user_session_path
  end

  it 'should get dashboard as admin' do
    sign_in @admin_user
    get :dashboard
    assert_response :success
  end

  it 'should be get 404 if not admin' do
    sign_in @user
    get :dashboard
    assert_response :not_found
  end

  it 'should update all the w000ts' do
    sign_in @admin_user
    expect{
      post :check_all_w000ts
    }.to change { UrlLifeChecker.jobs.size }.by(W000t.all.count)
    expect(response).to redirect_to('where_i_came_from')
    assert_equal 'All w000t will be checked soon', flash[:notice]
  end

  it 'should check one url' do
    sign_in @admin_user
    expect{
      post :check_url, params: { admin: { short_url: @w000t.short_url } }
    }.to change { UrlLifeChecker.jobs.size }.by(1)
    expect(response).to redirect_to('where_i_came_from')
    assert_equal 'Task created', flash[:notice]
  end

  it 'should not create task to check url if none given' do
    sign_in @admin_user
    expect {
      post :check_url
    }.to raise_error(ActionController::ParameterMissing)
    expect{
      post :check_url, params: { admin: { url: 'fake argument' } }
    }.to change { UrlLifeChecker.jobs.size }.by(0)
  end

  it 'should reset sidekiq stats' do
    sign_in @admin_user
    allowed_params = %w( processed failed )
    allowed_params.each do |p|
      post :reset_sidekiq_stat, params: { sidekiq: { reset_param: p } }
      expect(response).to redirect_to('where_i_came_from')
      assert_equal "Sidekiq #{p} stat resetted", flash[:notice]
    end
  end

  it 'should not reset sidekiq stats with wrong params' do
    sign_in @admin_user
    wrong_params = %w( yo mama plop )
    wrong_params.each do |p|
      expect {
        post :reset_sidekiq_stat, params: { sidekiq: { reset_param: p } }
      }.to raise_error(ArgumentError)
    end
  end
end
