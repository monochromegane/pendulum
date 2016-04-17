module Pendulum::Command
  class Apply
    class ResultURL
      attr_accessor :client, :from, :to
      def initialize(client, from, to)
        self.client = client
        self.from   = from
        self.to     = to
      end

      def changed?
        from_uri = to_uri(from)
        to_uri   = mask(to_uri(to))

        uri_without_query(from_uri) != uri_without_query(to_uri) ||
          query_hash(from_uri) != query_hash(to_uri)
      end

      private

      def mask(uri)
        uri.password = '***' if uri.user
        uri
      end

      def uri_without_query(uri)
        uri.to_s.split('?').first
      end

      def query_hash(uri)
        Hash[URI::decode_www_form(uri.query || '')]
      end

      def to_uri(url)
        return URI.parse(url) if ( url.empty? || url.include?('://') )

        # use result
        name, table  = url.split(':', 2)
        table, query = table.split('?', 2)

        result = result_by(name)
        return URI.parse(url) unless result

        uri = URI.parse(result.url)
        uri.path += "/#{table}"
        if uri.query
          uri.query += "&#{query}"
        else
          uri.query = query
        end
        uri
      end

      def results
        @results ||= client.results
      end

      def result_by(name)
        results.find{|r| name == r.name}
      end
    end
  end
end
