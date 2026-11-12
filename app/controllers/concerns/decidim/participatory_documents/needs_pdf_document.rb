# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This module provides methods and helpers for the pdf_viewer/editor
    module NeedsPdfDocument
      extend ActiveSupport::Concern

      included do
        helper_method :document, :box_color_as_rgba, :pdf_custom_style, :all_suggestions

        protected

        def document
          @document ||= Decidim::ParticipatoryDocuments::Document.find_by(component: current_component)
        end

        def all_suggestions
          @all_suggestions ||= begin
            manifest = document.component.manifest.export_manifests.find { |man| man.name == :suggestions }
            manifest.collection.call(document.component, current_user, :my_suggestions)
          end
        end

        def box_color_as_rgba(document, opacity: nil)
          opacity ||= document.box_opacity
          color = valid_box_color(document)
          return "rgba(30, 152, 215, 0.12);" unless color && opacity.present?

          color + (opacity * 2.55).round.to_s(16).rjust(2, "0")
        end

        def box_color_as_hsla(document, opacity: 0.95)
          color = valid_box_color(document)
          return "hsla(213, 48%, 90%, #{opacity});" unless color

          r, g, b = hex_to_rgb(color)
          h, s, _l = rgb_to_hsl(r, g, b)

          "hsla(#{h}, #{s}%, 90%, #{opacity})"
        end

        def pdf_custom_style
          return if document.blank?

          @pdf_custom_style ||= begin
            css = <<~CSS
              <style media="all">
                :root {
                  --box-color: #{valid_box_color(document) || "#1E98D7"};
                  --box-color-rgba: #{box_color_as_rgba(document)};
                  --notifications-color-rgba: #{box_color_as_rgba(document, opacity: 60)};
                  --suggestions-modal-color-hsla: #{box_color_as_hsla(document, opacity: 0.95)};
                }
              </style>
            CSS
            css.html_safe
          end
        end

        private

        # pdf.js fetches the file through an ActiveStorage redirect, so a remote
        # storage service has to be allowed by the connect-src directive.
        def append_storage_host_to_csp
          return unless document&.file&.attached?

          origin = URI.parse(document.file.blob.url).origin
          content_security_policy.append_csp_directive("connect-src", origin) unless origin == request.base_url
        end

        def valid_box_color(document)
          document.box_color.to_s[/\A#\h{6}\z/]
        end

        def hex_to_rgb(hex_string)
          hex_string = hex_string.delete("#")
          r = hex_string[0..1].to_i(16)
          g = hex_string[2..3].to_i(16)
          b = hex_string[4..5].to_i(16)
          [r, g, b]
        end

        def rgb_to_hsl(red, green, blue)
          red /= 255.0
          green /= 255.0
          blue /= 255.0
          c_max = [red, green, blue].max
          c_min = [red, green, blue].min
          delta = c_max - c_min

          h = 0
          s = 0
          l = (c_max + c_min) / 2.0

          if delta.positive?
            h =
              if c_max == red
                ((green - blue) / delta) % 6
              elsif c_max == green
                ((blue - red) / delta) + 2
              else
                ((red - green) / delta) + 4
              end

            s = delta / (1 - ((2 * l) - 1).abs)
          end

          h = (h * 60).round
          s = (s * 100).round
          l = (l * 100).round

          [h, s, l]
        end
      end
    end
  end
end
