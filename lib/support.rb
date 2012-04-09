require 'active_support'

# STI-Client support for ActiveResource
class ActiveResource::Base
  def self.instantiate_record(record, prefix_options = {})
    if not record["type"].nil?
      # this looks like an STI reply, see if we actually have the type available
      begin
        kls = Object.const_get(record["type"])
      rescue NameError
      end
    end

    kls = self if kls.nil?
    kls.new(record).tap do |resource|
      resource.prefix_options = prefix_options
    end
  end
  alias :sti_original_initialize :initialize
  def initialize(attributes = {})
    sti_original_initialize(attributes)
    @attributes[:type] = self.class.name unless self.class.superclass == ActiveResource::Base
  end
end
