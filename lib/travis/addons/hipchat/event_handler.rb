module Travis
  module Addons
    module Hipchat

      # Publishes a build notification to hipchat rooms as defined in the
      # configuration (`.travis.yml`).
      #
      # Hipchat credentials are encrypted using the repository's ssl key.
      class EventHandler < Event::Handler
        API_VERSION = 'v2'

        EVENTS = /build:finished/

        def handle?
          enabled? && targets.present? && config.send_on_finished_for?(:hipchat)
        end

        def handle
          Travis::Addons::Hipchat::Task.run(:hipchat, payload, targets: targets)
        end

        def targets
          @targets ||= config.notification_values(:hipchat, :rooms)
        end

        private

          def enabled?
            enabled = config.notification_values(:hipchat, :on_pull_requests)
            enabled = false if enabled.nil? or !(!!enabled == enabled) # configuration returns a non boolean if key is not found
            pull_request? ? enabled : true
          end

          Instruments::EventHandler.attach_to(self)
      end
    end
  end
end

