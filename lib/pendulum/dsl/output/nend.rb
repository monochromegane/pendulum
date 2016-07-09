module Pendulum::DSL::Output
  class Nend < Base
    define_setter :api_key, :type, :name,
                  :retry_delay, :retry_limit

    def to_url
      {
        type:                   'nend',
        apikey:                 @api_key,
        target_type:            @type,
        target_name:            @name,
        retry_initial_wait_sec: @retry_delay || 5,
        retry_limit:            @retry_limit || 4,
        application_name:       'Treasure Data nend Output'
      }.to_json
    end
  end
end

