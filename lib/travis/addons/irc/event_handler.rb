module Travis
  module Addons
    module Irc

      # Publishes a build notification to IRC channels as defined in the
      # configuration (`.travis.yml`).
      class EventHandler < Event::Handler
        API_VERSION = 'v2'

        EVENTS = 'build:finished'

        def handle?
          enabled? && channels.present? && config.send_on_finished_for?(:irc)
        end

        def handle
          Travis::Addons::Irc::Task.run(:irc, payload, channels: channels)
        end

        def channels
          @channels ||= config.notification_values(:irc, :channels)
        end

        private

          def enabled?
            enabled = config.notification_values(:irc, :on_pull_requests)
            enabled = false if enabled.nil? or !(!!enabled == enabled) # configuration returns a non boolean if key is not found
            pull_request? ? enabled : true
          end

          Instruments::EventHandler.attach_to(self)
      end
    end
  end
end

