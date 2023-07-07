# frozen_string_literal: true

module Decidim
  module ParticipatoryDocuments
    # This module provides methods and helpers for the pdf_viewer/editor
    module NeedsPdfDocument
      extend ActiveSupport::Concern

      included do
        helper_method :document, :box_color_as_rgba, :pdf_custom_style

        protected

        def document
          @document ||= Decidim::ParticipatoryDocuments::Document.find_by(component: current_component)
        end

        def box_color_as_rgba(document, opacity: nil)
          opacity ||= document.box_opacity
          return "rgba(30, 152, 215, 0.12);" unless document.box_color.present? && opacity.present?

          document.box_color + (opacity * 2.55).round.to_s(16).rjust(2, "0")
        end

        def box_color_as_hsla(document, opacity: 0.95)
          return "hsla(213, 48%, 90%, #{opacity});" if document.box_color.blank?

          hex_string = document.box_color

          r, g, b = hex_to_rgb(hex_string)
          h, s, _l = rgb_to_hsl(r, g, b)

          "hsla(#{h}, #{s}%, 90%, #{opacity})"
        end

        def pdf_custom_style
          return if document.blank?

          @pdf_custom_style ||= begin
            css = <<~CSS
              <style media="all">
                :root {
                  --box-color: #{document.box_color || "#1E98D7"};
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
                (blue - red) / delta + 2
              else
                (red - green) / delta + 4
              end

            s = delta / (1 - (2 * l - 1).abs)
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
