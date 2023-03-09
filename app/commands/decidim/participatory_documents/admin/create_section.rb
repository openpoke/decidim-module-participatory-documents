# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class CreateSection < Rectify::Command
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
              create_section
            end
            broadcast(:ok, section)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :document, :section

        def create_section
          @section = Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::Section,
            form.current_user,
            **attributes
          )
        end

        def attributes
          {
            title: form.title
          }.merge(document: document)
        end
      end
    end
  end
end
