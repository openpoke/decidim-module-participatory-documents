# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class PublishDocument < Rectify::Command
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
          @document.publish!

          broadcast(:ok)
        end
      end
    end
  end
end
