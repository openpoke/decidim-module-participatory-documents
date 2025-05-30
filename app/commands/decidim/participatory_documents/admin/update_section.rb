# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UpdateSection < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, document)
          @form = form
          @document = document
        end

        def call
          return broadcast(:invalid) if form.invalid?

          begin
            transaction do
              update_section
            end
            broadcast(:ok, section)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :document

        def update_section
          @zone = Decidim.traceability.update!(
            section,
            form.current_user,
            **attributes
          )
        end

        def attributes
          {
            title: form.title
          }.merge(document:)
        end

        def section
          @section ||= document.sections.find(form.id)
        end
      end
    end
  end
end
