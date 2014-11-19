require 'azon'
require 'redis'
require 'cache'

class AzonTest
  def initialize
    @redis = Redis.new
    @cache = Cache.new
    Azon.subscribe('cache_invalid', method(:msg_handler))
  end

  def find(id)
    @cache[id] ||= @redis.get id

    @cache[id]
  end

  def save(id, value)
    @redis.set id, value
    Azon.publish('cache_invalid', 'invalidate_cache|'+id.to_s)
  end

  def msg_handler(msg)
    msg = msg.split('|')

    if msg.first == 'invalidate_cache'
      invalidate(msg.last)
    end
  end

  def invalidate(id)
    @cache.invalidate(id)
  end
end