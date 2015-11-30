class Unpacker
  def initialize(message)
    @message = message
    @offset = 0
    @previous_labels = {}
  end

  def read_byte
    byte = @message[@offset..@offset].unpack("C")[0]
    @offset += 1
    byte
  end

  def read_string(length)
    str = @message[@offset..(@offset + length -1)]
    @offset += length
    str
  end

  def read_int16
    i = @message[@offset..-1].unpack("S>")[0]
    @offset += 2
    i
  end

  def read_int32
    i = @message[@offset..-1].unpack("L>")[0]
    @offset += 4
    i
  end

  def read_domain_name
    offset = @offset
    components = []

    while true
      component_length = read_byte

      break if component_length == 0
      
      if component_length & 192 == 192
        pointer_offset_h = component_length & 63
        pointer_offset_l = read_byte
        pointer_offset = pointer_offset_h << 8 + pointer_offset_l

        components << @previous_labels[pointer_offset]
        
        return components.join(".")
      else 
        components << read_string(component_length)
      end
    end

    label = components.join(".")
    @previous_labels[offset] = label
    label
  end
end