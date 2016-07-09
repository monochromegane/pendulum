require 'highline'

module Pendulum::Command
  class Apply
    class Schedule
      attr_accessor :client, :from, :to, :dry_run, :force, :color
      def initialize(client, from, to, dry_run=false, force=false, color=false)
        self.client  = client
        self.from    = from
        self.to      = to
        self.dry_run = dry_run
        self.force   = force
        self.color   = color
      end

      def apply
        case
        when will_create? then create
        when will_update? then update
        when will_delete? then delete
        end
      end

      private

      def create
        puts message_for_create
        client.create_schedule(to.name, to.to_params) unless dry_run?
      end

      def update
        puts message_for_update
        puts message_for_diff if has_diff?
        if force? || has_diff?
          client.update_schedule(to.name, to.to_params) unless dry_run?
        end
      end

      def delete
        puts message_for_delete
        client.delete_schedule(from.name) if force? && !dry_run?
      end

      def will_create?
        !from && to
      end

      def will_update?
        from && to
      end

      def will_delete?
        from && !to
      end

      def has_diff?
        !diff.empty?
      end

      def diff
        return {} unless will_update?

        @diff ||= begin
                    default_params.merge(to.to_params).select do |k, v|
                      if k == :result || k == :result_json
                        result_url_changed?(from.result_url, v)
                      else
                        v != from.send(k)
                      end
                    end
                  end
      end

      def masked_diff
        return diff unless diff.key?(:result)

        masked = diff.dup

        if masked[:result].start_with?('{') || diff.key?(:result_json)
          hashed_result = JSON.parse(masked[:result])
          hashed_result.delete('apikey')
          masked[:result] = hashed_result.to_json
        else
          uri = URI.parse(masked[:result])
          uri.password = '***' if uri.user
          masked[:result] = uri.to_s
        end

        masked
      end

      def message_for_create
        colorize message_for(:create), :cyan
      end

      def message_for_update
        if force? || has_diff?
          colorize message_for(:update), :green
        else
          colorize message_with_dry_run("No change schedule: #{name}"), :blue
        end
      end

      def message_for_delete
        if force?
          colorize message_for(:delete), :red
        else
          colorize message_with_dry_run("Undefined schedule (pass `--force` if you want to remove): #{name}"), :yellow
        end
      end

      def message_with_dry_run(message)
        message += ' (dry-run)' if dry_run?
        message
      end

      def message_for(action)
        message_with_dry_run "#{action.to_s.capitalize} schedule: #{name}"
      end

      def message_for_diff
        message = masked_diff.map do |name, value|
          "  set #{name}=#{value}"
        end.join("\n")
        colorize message, :green
      end

      def name
        (from && from.name) || (to && to.name)
      end

      def dry_run?
        dry_run
      end

      def force?
        force
      end

      def color?
        color
      end

      def default_params
        {
          database:    '',
          query:       nil,
          retry_limit: 0,
          priority:    0,
          cron:        nil,
          timezone:    'Asia/Tokyo', # TODO: require timezone.
          delay:       0,
          result:      ''
        }
      end

      def result_url_changed?(from_url, to_url)
        Apply::ResultURL.new(client, from_url, to_url).changed?
      end

      def colorize(message, color)
        return message unless color?
        h.color message, color
      end

      def h
        @h ||= HighLine.new
      end
    end
  end
end

