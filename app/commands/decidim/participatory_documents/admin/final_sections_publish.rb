# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class FinalSectionsPublish < Rectify::Command
        # Public: Initializes the command.
        #
        # document - The document to publish.
        def initialize(document)
          @document = document
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # Returns nothing.
        def call
          final_publish

          broadcast(:ok)
        end

        private

        attr_reader :document

        def final_publish
          document.update!(final_publish: true)
          document.save!
        end
      end
    end
  end
end
