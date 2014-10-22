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

    @url_info_count_by_codes = UrlInfo.collection.aggregate(
      '$group' => {
        '_id' => '$http_code',
        count: { '$sum' => 1 }
      }
    )
  end

  def check_all_w000ts
    W000t.all.each { |w| w.url_info.create_task }
    redirect_to :back, notice: 'All w000t will be checked soon'
  end

  def check_url
    short_url = admin_params[:short_url]
    return redirect_to :back,
                       flash: { alert: 'Missing short url' } unless short_url
    # TODO : search by w000t and use create_task
    UrlLifeChecker.perform_async(short_url)
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
