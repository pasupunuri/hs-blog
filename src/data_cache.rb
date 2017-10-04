class DataCache
  REDIS = Redis.new
  SCOPE_KEY = 'blog_data_cache'
  attr_reader :cache_time

  def initialize(cache_time)
    @cache_time = cache_time
  end

  def set(key, data)
    payload=  { time: time, data: data }
    REDIS.hset(SCOPE_KEY, key, payload.to_json)
  end

  def time
    Time.now.utc
  end

  def get(key)
    data = REDIS.hget(SCOPE_KEY, key)
    if data && (data = JSON.parse(data, symbolize_names: true)) && !expired?(data)
      data[:data]
    else
      nil
    end
  end

  def expired?(data)
    (DateTime.parse(data[:time]).to_time + (cache_time.to_i * 60)) < time
  end
end