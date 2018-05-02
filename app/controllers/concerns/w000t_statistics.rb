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

  def w000t_top_ten(user = nil)
    query = [
      {
        '$project' => {
          '_id' => '$_id',
          'url' => '$url_info.url',
          'number_of_click' => '$number_of_click',
          'user_id' => '$user_id'
        }
      },
      { '$sort' => { 'number_of_click' => -1 } },
      { '$limit' => 10 }
    ]

    # Filter by user
    query.unshift('$match' => { user_id: user.id }) if user

    W000t.collection.aggregate(query).map do |r|
      r[:user] = 'Anonymous'
      r[:user] = User.find(r[:user_id]).pseudo if r[:user_id]
      r
    end
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

  def w000t_clicks_by_day(w000t = nil)
    query = [
      # Flatten all the clicks
      { '$unwind' => '$clicks' },
      # Get year, month and day from created_at
      {
        '$project' => {
          _id: 0,
          day: { '$dayOfMonth' => '$clicks.created_at' },
          month: { '$month' => '$clicks.created_at' },
          year: { '$year' => '$clicks.created_at' }
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

    # Filter for this w000t w000t
    query.unshift('$match' => { _id: w000t.id }) if w000t

    result = {}
    W000t.collection.aggregate(query).map do |r|
      result[r[:_id]] = r[:count]
    end
    result
  end

  def w000t_count_by_user(user = nil)
    query = [
      {
        '$group' => {
          '_id' => '$user_id',
          count: { '$sum' => 1 }
        }
      },
      { '$sort' => { 'count' => -1 } }
    ]

    # Filter by user
    query.unshift('$match' => { user_id: user.id }) if user

    result = {}
    W000t.collection.aggregate(query).map do |r|
      pseudo = r[:_id] ? User.find(r[:_id].to_s).pseudo : 'Anonymous'
      result[pseudo] = r[:count]
    end
    result
  end

  def w000t_count_by_status(user = nil)
    query = [
      {
        '$group' => {
          '_id' => '$status',
          count: { '$sum' => 1 }
        }
      },
      { '$sort' => { 'count' => -1 } }
    ]

    # Filter by user
    query.unshift('$match' => { user_id: user.id }) if user

    W000t.collection.aggregate(query)
  end

  def w000t_count_by_type(user = nil)
    query = [
      {
        '$group' => {
          '_id' => '$url_info.type',
          count: { '$sum' => 1 }
        }
      },
      { '$sort' => { 'count' => -1 } }
    ]

    # Filter by user
    query.unshift('$match' => { user_id: user.id }) if user

    result = {}
    W000t.collection.aggregate(query).map do |r|
      type = r[:_id] ? r[:_id] : 'Undefined'
      result[type] = r[:count]
    end
    result
  end

  def user_login_count(user = nil)
    query = [
      {
        '$project' => {
          '_id' => 0,
          'sign_in_count' => '$sign_in_count',
          'last_sign_in_at' => '$last_sign_in_at',
          'pseudo' => '$pseudo'
        }
      },
      { '$sort' => { 'sign_in_count' => -1 } }
    ]

    # Filter by user
    query.unshift('$match' => { user_id: user.id }) if user

    result = {}
    User.collection.aggregate(query).map do |r|
      result[r[:pseudo]] = {
        sign_in_count: r[:sign_in_count],
        last_sign_in_at: r[:last_sign_in_at]
      }
    end
    result
  end
end
