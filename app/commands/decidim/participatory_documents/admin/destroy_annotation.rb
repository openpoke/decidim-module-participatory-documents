# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class DestroyAnnotation < Rectify::Command
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
              destroy_annotation
            end
            broadcast(:ok)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def destroy_annotation
          Decidim.traceability.perform_action!(
            :delete,
            annotation,
            current_user
          ) do
            annotation.destroy!
          end
        end

        def annotation
          @annotation ||= document.annotations.find_by!(uid: form.id)
        end
      end
    end
  end
end
