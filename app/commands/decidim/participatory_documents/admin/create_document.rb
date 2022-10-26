# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class CreateDocument  < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end
        def call
          return broadcast(:invalid) if form.invalid?


          transaction do
            create_document
            # create_attachment if process_attachments?
          end
          broadcast(:ok, document)
        end

        private
        attr_reader :form, :document
        def create_document
          @document = Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::Document,
            form.current_user,
            component: form.current_component,
            author: form.current_user,
            title: form.title,
            description: form.description
          )

        end
      end
    end
  end
end
