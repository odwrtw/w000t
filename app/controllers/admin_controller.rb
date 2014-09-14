# AdminController
class AdminController < ApplicationController
  before_action :authenticate_user!, :check_admin
  before_action :check_sidekiq_params, only: [:reset_sidekiq_stat]

  def dashboard
    @total_w000t_number = W000t.all.count
    @total_user_number = User.all.count
    @total_url_number = User.all.count

    # User info
    @user_data = {}
    User.all.each do |user|
      @user_data[user.pseudo] = user.attributes
      @user_data[user.pseudo][:w000t_counts] = user.w000ts.count
    end
  end

  def check_all_w000ts
    W000t.all.each { |w| UrlLifeChecker.perform_async(w.long_url) }
    render json: { status: 'ok' }
  end

  def check_url
    url = admin_params[:long_url]
    return render json: { error: 'No url to check' } unless url
    UrlLifeChecker.perform_async(url)
    redirect_to :back, notice: 'Task created'
  end

  def reset_sidekiq_stat
    Sidekiq.redis { |c| c.del("stat:#{@reset_param}") }
    render json: { status: 'ok' }
  end

  private

  def check_admin
    redirect_to root_path unless current_user.admin?
  end

  def admin_params
    params.require(:admin).permit(:long_url)
  end

  def sidekiq_params
    params.require(:sidekiq).permit(:reset_param)
  end

  def check_sidekiq_params
    allowed_params = %w( processed failed )
    @reset_param = sidekiq_params[:reset_param]
    return if allowed_params.include? @reset_param
    fail ArgumentError, 'Unauthorized argument'
  end
end
