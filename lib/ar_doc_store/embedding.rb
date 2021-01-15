# frozen_string_literal: true

module ArDocStore
  module Embedding
    def self.included(mod)
      mod.send :extend, ClassMethods
      mod.send :include, InstanceMethods
    end

    module ClassMethods
      def embeds_many(assn_name, *args)
        json_attribute assn_name, :embeds_many, *args
      end

      def embeds_one(assn_name, *args)
        json_attribute assn_name, :embeds_one, *args
      end
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

      def validate_embeds_many(assn_name)
        if records = public_send(assn_name)
          records.each { |record| embed_valid?(assn_name, record) }
        end
      end

      def validate_embeds_one(assn_name)
        record = public_send(assn_name)
        embed_valid?(assn_name, record) if record
      end

    end
  end
end
