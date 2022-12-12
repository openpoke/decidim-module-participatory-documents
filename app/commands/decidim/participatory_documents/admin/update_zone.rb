# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    module Admin
      class UpdateZone < Rectify::Command
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
              update_zone

              if form.published?
                publish_zone
              else
                unpublish_zone
              end
            end
            broadcast(:ok, zone)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form

        def publish_zone
          @zone.publish!
        end

        def unpublish_zone
          @zone.unpublish!
        end

        def update_zone
          @zone = Decidim.traceability.update!(
            zone,
            form.current_user,
            **attributes
          )
        end

        def attributes
          {
            title: form.title,
            description: form.description,
            uid: form.uid,
            closed_at: form.closed? ? (zone.closed_at || Time.zone.now) : nil,
            private: form.private?,
          }.merge(document: document)
        end

        def zone
          @zone ||= document.zones.find_by!(uid: form.uid)
        end
      end
    end
  end
end
