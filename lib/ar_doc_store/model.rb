module ArDocStore
  
  module Model
    
    def self.included(mod)
      mod.send :include, ArDocStore::Storage
      mod.send :include, ArDocStore::Embedding
    end
    
  end
end