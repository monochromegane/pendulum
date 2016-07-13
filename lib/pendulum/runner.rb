require 'optparse'


module Pendulum
  DEFAULT_SCHEDFILE = 'Schedfile'
  class Runner
    def run(argv=ARGV)
      api_key = ENV['TD_API_KEY']
      mode    = nil
      dry_run = false
      force   = false
      color   = true
      options = {
        file:    DEFAULT_SCHEDFILE,
        env:     :development,
      }
      output  = DEFAULT_SCHEDFILE

      opt.on('-k', '--apikey=KEY') {|v| api_key = v }

      # apply
      opt.on('-a', '--apply')           {    mode   = :apply    }
      opt.on('-E', '--environment=ENV') {|v| options[:env]  = v }
      opt.on('-f', '--file=FILE')       {|v| options[:file] = v }
      opt.on('',   '--dry-run')         {    dry_run = true     }
      opt.on('',   '--force')           {    force   = true     }
      opt.on('',   '--no-color')        {    color   = false    }

      # export
      opt.on('-e', '--export') do
        mode = :export
        options.delete(:file)
      end
      opt.on('-o', '--output=FILE') {|v| output = v }

      opt.parse!(argv) rescue return usage $!
      return usage if (api_key.nil? || mode.nil?)

      begin
        client = Client.new(api_key, options)
        case mode
        when :apply
          client.apply(dry_run: dry_run, force: force, color: color)
        when :export
          client.export(output)
        end
      rescue
        $stderr.puts $!
        return 1
      end

      return 0
    end

    private

    def usage(err=nil)
      puts err if err
      puts opt.help
      err ? 1 : 0
    end

    def opt
      @opt ||= OptionParser.new
    end
  end
end
