# frozen_string_literal: true

module ArDocStore
  module Attributes
    module CallbackSupport
      def self.included(mod)
        mod.send :include,  ActiveSupport::Callbacks
        mod.send :extend, ClassMethods
        mod.define_callbacks :build
      end

      module ClassMethods
        def before_build(method)
          set_callback :build, :before, method
        end

        def after_build(method)
          set_callback :build, :after, method
        end
      end
    end
  end
end
