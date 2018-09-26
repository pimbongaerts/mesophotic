class SpeciationJob < ApplicationJob
  queue_as :default

  def perform(*species)
    # TODO Add associations with publications
    # Remove all associations with publicaitons
    # Redo the assoications
    puts species.to_yaml
  end
end
