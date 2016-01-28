# frozen-string-literal: true

require 'thamble'
require 'active_support/core_ext/string/output_safety'
ActiveSupport::SafeBuffer.send(:include, Thamble::Raw)

module Thamble
  module RailsHelper
    def thamble(*a, &block)
      raw Thamble.table(*a, &block)
    end
  end
end
