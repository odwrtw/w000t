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

    @url_info_count_by_codes = W000t.collection.aggregate([
      {
        '$group' => {
          '_id' => '$url_info.http_code',
          count: { '$sum' => 1 }
        }
      },
      { '$sort' => { 'count' => -1 } }
    ])

    @url_info_top_ten_url = W000t.collection.aggregate([
      { '$group' => {
        '_id' => '$url_info.url',
        count: { '$sum' => 1 }
      } },
      { '$sort' => { 'count' => -1 } },
      { '$limit' => 10 }
    ])

    @w000t_top_ten = W000t.collection.aggregate([
      {
        '$project' => {
          '_id' => '$url_info.url',
          'number_of_click' => '$number_of_click',
          'user_id' => '$user_id'
        }
      },
      { '$sort' => { 'number_of_click' => -1 } },
      { '$limit' => 10 }
    ]).map! do |r|
      r[:user] = 'Anonymous'
      r[:user] = User.find(r[:user_id]).pseudo if r[:user_id]
      r
    end

    @result = {}
    @w000t_by_day = W000t.collection.aggregate([
      # Get year, month and day from created_at
      {
        '$project' => {
          _id: 0,
          day: { '$dayOfMonth' => '$created_at' },
          month: { '$month' => '$created_at' },
          year: { '$year' => '$created_at' }
        }
      },
      # Concat the year, month and day
      {
        '$project' => {
          date: {
            '$concat' => [
              { '$substr' => ['$year', 0, 4] }, '-',
              { '$substr' => ['$month', 0, 2] }, '-',
              { '$substr' => ['$day', 0, 2] }
            ]
          }
        }
      },
      # Use the concateneted string to group and count
      {
        '$group' => {
          _id: '$date', count: { '$sum' => 1 }
        }
      }
      # Map the whole thing to satisfy chartkick
    ]).map do |r|
      @result[r[:_id]] = r[:count]
    end

    @w000t_by_day = @result
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
