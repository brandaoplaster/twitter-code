module Rack
  class Attack
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    # Allow all local traffic
    safelisrt('allow-localhost') do |req|
      req.ip == '127.0.0.1' || req.ip == '::1'
    end

    # Allow an IP address to make 5 request every 3 second
    throttle('req/ip', limit: 5, period: 5, &:ip)
  end
end
