require "sunspot/queue/sidekiq/index_job"
require "sunspot/queue/sidekiq/removal_job"

module Sunspot::Queue::Sidekiq
  class Backend
    attr_reader :configuration, :delay_for

    def initialize(configuration = Sunspot::Queue.configuration, delay_for = 5.seconds)
      @configuration = configuration
      @delay_for = delay_for
    end

    # Job needs to include Sidekiq::Worker
    def enqueue(job, klass, id)
      job.perform_in(@delay_for, klass.to_s, id)
      # job.perform_async(klass.to_s, id)
    end

    def index(klass, id)
      enqueue(index_job, klass, id)
    end

    def remove(klass, id)
      enqueue(removal_job, klass, id)
    end

    private

    def index_job
      configuration.index_job || ::Sunspot::Queue::Sidekiq::IndexJob
    end

    def removal_job
      configuration.removal_job || ::Sunspot::Queue::Sidekiq::RemovalJob
    end
  end
end
