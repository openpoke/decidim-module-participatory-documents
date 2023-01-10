# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UpdateAnnotation < Rectify::Command
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
              annotation.assign_attributes(**attributes)
              update_annotation! if annotation.changed?
            end
            broadcast(:ok, annotation)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def update_annotation!
          @annotation = Decidim.traceability.update!(
            annotation,
            form.current_user,
            **attributes
          )
        end

        def attributes
          {
            page_number: form.page_number,
            rect: form.rect,
            uid: form.id
          }.merge(section: section)
        end

        def section
          @section ||= Decidim::ParticipatoryDocuments::Section.where(document: document, uid: form.group).first_or_create
        end

        def annotation
          @annotation ||= document.annotations.find_by!(uid: form.id)
        end
      end
    end
  end
end
