module ArDocStore
  module Embedding
      module Core

      def self.included(mod)
        mod.send :include, EmbedsOne
        mod.send :include, EmbedsMany
        mod.send :include, InstanceMethods
      end
    
      module InstanceMethods
      
        # Returns whether or not the association is valid and applies any errors to
        # the parent, <tt>self</tt>, if it wasn't. Skips any <tt>:autosave</tt>
        # enabled records if they're marked_for_destruction? or destroyed.
        def embed_valid?(assn_name, record)
          unless valid = record.valid?
            record.errors.each do |attribute, message|
              attribute = "#{assn_name}.#{attribute}"
              errors[attribute] << message
              errors[attribute].uniq!
            end
          end
          valid
        end

      end
    end
  end
end
