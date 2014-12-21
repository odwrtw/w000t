# AdminController
class AdminController < ApplicationController
  include W000tStatistics

  before_action :authenticate_user!, :check_admin
  before_action :check_sidekiq_params, only: [:reset_sidekiq_stat]

  def dashboard
    @total_w000t_number = W000t.all.count
    @total_user_number = User.all.count
    @total_url_number = User.all.count

    # User info
    # Get data from W000tStatistics concern
    @w000t_top_ten = w000t_top_ten
    @w000t_count_by_user = w000t_count_by_user
    @url_info_count_by_codes = url_info_count_by_codes
    @url_info_top_ten_url = url_info_top_ten_url
    @w000t_by_day = w000t_by_day
    @user_login_count = user_login_count
    @w000t_count_by_status = w000t_count_by_status
    @w000t_count_by_type = w000t_count_by_type
  end

  def check_all_w000ts
    W000t.all.each(&:create_task)
    redirect_to :back, notice: 'All w000t will be checked soon'
  end

  def check_url
    short_url = admin_params[:short_url]
    return redirect_to :back,
                       flash: { alert: 'Missing short url' } unless short_url
    w000t = W000t.find(short_url)
    return redirect_to :back,
                       flash: { alert: 'Unknown w000t' } unless w000t
    w000t.create_task
    redirect_to :back, notice: 'Task created'
  end

  def reset_sidekiq_stat
    Sidekiq.redis { |c| c.del("stat:#{@reset_param}") }
    redirect_to :back, notice: "Sidekiq #{@reset_param} stat resetted"
  end

  private

  def check_admin
    redirect_to root_path unless current_user.admin?
  end

  def admin_params
    params.require(:admin).permit(:short_url)
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
