class Unpacker
  def initialize(message)
    @message = message
    @offset = 0
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
end