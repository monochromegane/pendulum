module Pendulum::DSL
  class Result
    attr_accessor :type, :output

    def initialize(type, &block)
      self.type = type
      self.output = output_by(type)
      self.output.instance_eval(&block) if block_given?
    end

    def to_url
      output.to_url
    end

    private

    def output_by(type)
      case type.to_sym
      when :treasure_data, :td
        Output::TreasureData.new
      when :postgresql
        Output::Postgresql.new
      when :nend
        Output::Nend.new
      else
        Output::Result.new(type)
      end
    end
  end
end
