# frozen-string-literal: true

require_relative '../thamble'
require 'active_support/core_ext/string/output_safety'
ActiveSupport::SafeBuffer.send(:include, Thamble::Raw)

module Thamble
  module RailsHelper
    def thamble(*a, &block)
      Thamble.table(*a, &block).html_safe
    end
  end
end
