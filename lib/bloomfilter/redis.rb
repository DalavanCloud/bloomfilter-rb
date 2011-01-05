module BloomFilter
  class Redis < Filter

    def initialize(opts = {})
      @opts = {
        :size    => 100,
        :hashes  => 4,
        :seed    => Time.now.to_i,
        :bucket  => 3,
        :ttl => false,
        :server => {}
      }.merge opts
      @db = ::Redis.new(@opts[:server])
    end

    def insert(key, ttl=nil)
      indexes_for(key) { |idx| @db.setbit 'redis', idx, 1 }
    end
    alias :[]= :insert

    def include?(*keys)
      keys.each do |key|
        indexes_for(key) do |idx|
          return false if @db.getbit('redis', idx).zero?
        end
      end

      true
    end
    alias :key? :include?

    def delete(key)
      indexes_for(key) do |idx|
        @db.setbit 'redis', idx, 0
      end
    end

    def clear
      @db.set 'redis', 0
    end

    def num_set
      @db.strlen 'redis'
    end
    alias :size :num_set

    def stats
      printf "Number of filter buckets (m): %d\n" % @opts[:size]
      printf "Number of filter hashes (k) : %d\n" % @opts[:hashes]
    end

    private

      # compute index offsets for provided key
      def indexes_for(key)
        indexes = []
        @opts[:hashes].times do |i|
          yield Zlib.crc32("#{key}:#{i+@opts[:seed]}") % @opts[:size]
        end
      end

  end
end