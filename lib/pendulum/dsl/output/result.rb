module Pendulum::DSL::Output
  class Result < Base
    define_setter :table, :schema, :method, :mode

    def initialize(name)
      @name = name
      super()
    end

    def to_url
      url = "#{@name}:#{@table}"
      with_options(url, :schema, :method, :mode)
    end
  end
end
