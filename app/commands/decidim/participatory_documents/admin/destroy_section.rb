# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class DestroySection < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form, document)
          @form = form
          @document = document
        end

        def call
          # we do not really need to validate the form, since we are removing the object
          # return broadcast(:invalid, code: form.errors) if form.invalid? #
          # TODO: Add annotation constraint ?!
          # return broadcast(:invalid, code: 2) if zone.annotations.length > 1
          # TODO: ADD Comment existance validation
          # return broadcast(:invalid) if form.invalid?

          transaction do
            destroy_section
          end
          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid, code: 3)
        end

        private

        attr_reader :form, :document

        def destroy_section
          Decidim.traceability.perform_action!(
            :delete,
            section,
            form.current_user
          ) do
            section.annotations.destroy_all
            section.destroy!
          end
        end

        def section
          @section ||= document.sections.find_by!(uid: form.uid)
        end
      end
    end
  end
end
