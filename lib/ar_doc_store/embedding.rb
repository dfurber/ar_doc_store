module ArDocStore
  module Embedding
    def self.included(base)
      base.send :include, Core
    end
  end
end
