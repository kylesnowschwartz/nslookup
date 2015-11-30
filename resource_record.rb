class ResourceRecord
  attr_reader :rdata
  def initialize(name, type, _class, ttl, rdlength, rdata)
    @name = name
    @type = type
    @class = _class
    @ttl = ttl
    @rdlength = rdlength 
    @rdata = rdata
  end

  def self.from_bytes(unpacker)
    name = unpacker.read_domain_name
    type = unpacker.read_int16
    _class = unpacker.read_int16
    ttl = unpacker.read_int32
    rdlength = unpacker.read_int16
    rdata = unpacker.read_string(rdlength)

    ResourceRecord.new(name, type, _class, ttl, rdlength, rdata)
  end
end