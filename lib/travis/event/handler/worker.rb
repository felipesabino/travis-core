module Travis
  module Event
    class Handler

      # Enqueues a remote job payload so it can be picked up and processed by a
      # Worker.
      class Worker < Handler
        include do
          API_VERSION = 'v0'

          EVENTS = /job:.*:created/

          class << self
            def enqueue(job)
              new('enqueued', job).notify
            end
          end

          def notify
            handle if handle?
          end

          private

            def handle?
              true
            end

            def handle
              ActiveSupport::Notifications.instrument('notify', :target => self, :args => [event, object, data]) do
                enqueue
              end
            end

            def enqueue
              publisher.publish(payload, :properties => { :type => payload['type'] })
            end

            def publisher
              object.is_a?(Job::Configure) ? Travis::Amqp::Publisher.configure : Travis::Amqp::Publisher.builds(object.queue)
            end

            def payload
              Api.data(object, :for => 'worker', :type => object.class.name, :version => API_VERSION)
            end
        end
      end
    end
  end
end