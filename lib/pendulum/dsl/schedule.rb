module Pendulum::DSL
  class Schedule
    include Helper

    attr_accessor :name

    def initialize(name, &block)
      self.name = name
      self.instance_eval(&block) if block_given?
    end

    define_setter :database, :query, :timezone,
                  :delay, :retry_limit, :type

    def query_file(path)
      query(File.read(path))
    end

    def cron(cron)
      @cron = %i(hourly daily monthly).include?(cron) ? "@#{cron}" : cron
    end

    def priority(priority)
      @priority = priority.is_a?(Integer) ? priority : priority_id_of(priority)
    end

    def result_url(url)
      @result = url
    end

    def result(type, &block)
      result = Result.new(type, &block)
      @result = result.to_url
    end

    def result_json(type, hash = {})
      @result = {type: type}.merge(hash).to_json
    end

    def to_params
      instance_variables.inject({}) do |params, v|
        params[v.to_s.delete('@').to_sym] = instance_variable_get(v)
        params
      end
    end

    private

    def priority_id_of(name)
      case name.to_sym
      when :very_low  then -2
      when :low       then -1
      when :normal    then  0
      when :high      then  1
      when :very_high then  2
      else                  0
      end
    end
  end
end
