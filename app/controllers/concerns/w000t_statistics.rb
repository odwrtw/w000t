# Statistics for w000t
module W000tStatistics
  extend ActiveSupport::Concern

  def total_w000t_by_user(user)
    user.w000ts.count
  end

  # Group the url_info by code
  # Sort the result
  def url_info_count_by_codes(user = nil)
    query = [
      {
        '$group' => {
          '_id' => '$url_info.http_code',
          count: { '$sum' => 1 }
        }
      },
      { '$sort' => { 'count' => -1 } }
    ]

    # Filter by user
    query.unshift('$match' => { user_id: user.id }) if user

    W000t.collection.aggregate(query)
  end

  # Top ten of the most popular url_info
  def url_info_top_ten_url(user = nil)
    query = [
      {
        '$group' => {
          '_id' => '$url_info.url',
          count: { '$sum' => 1 }
        }
      },
      {
        '$sort' => { 'count' => -1 }
      },
      { '$limit' => 10 }
    ]

    # Filter by user
    query.unshift('$match' => { user_id: user.id }) if user

    W000t.collection.aggregate(query)
  end

  def w000t_by_day(user = nil)
    query = [
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
    ]

    # Filter by user
    query.unshift('$match' => { user_id: user.id }) if user

    result = {}
    W000t.collection.aggregate(query).map do |r|
      result[r[:_id]] = r[:count]
    end
    result
  end

  def w000ts_by_user
    user_data = {}
    User.all.each do |user|
      user_data[user.pseudo] = user.attributes
      user_data[user.pseudo][:w000t_counts] = user.w000ts.count
    end
    user_data
  end
end
