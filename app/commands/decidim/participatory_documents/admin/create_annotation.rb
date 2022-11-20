# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class CreateAnnotation < Rectify::Command
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
              create_annotation
            end
            broadcast(:ok, annotation)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :annotation

        def create_annotation
          @annotation = Decidim.traceability.create!(
            Decidim::ParticipatoryDocuments::Annotation,
            form.current_user,
            **attributes
          )
        end

        def attributes
          {
            annotation_type: form.annotation_type,
            thickness: form.thickness,
            page_index: form.page_index,
            rotation: form.rotation,
            opacity: form.opacity,
            scale: form.scale,
            paths: form.paths,
            color: form.color,
            rect: form.rect
          }.merge(document: document)
        end
      end
    end
  end
end
