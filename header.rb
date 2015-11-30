class Header
  OP_CODE_QUERY = 0
  OP_CODE_IQUERY = 1
  OP_CODE_STATUS = 2

  QR_QUERY = 0
  QR_RESPONSE = 1

  R_CODE_SUCCESS = 0

  attr_accessor :qd_count, :an_count, :ns_count, :ar_count

  def initialize(id, qr, op_code, tc, rd, ra, r_code, qd_count, an_count, ns_count, ar_count)
    @id = id
    @qr = qr
    @op_code = op_code
    @aa = 0
    @tc = tc
    @rd = rd
    @ra = ra
    @z = 0
    @r_code = r_code
    @qd_count = qd_count
    @an_count = an_count
    @ns_count = ns_count
    @ar_count = ar_count
  end

  def to_bytes
    packed1 = @qr << 7 | @op_code << 3 | @aa << 2 | @tc << 1 | @rd
    packed2 = @ra << 7 | @z << 4 |@r_code
    header_fields = [@id, packed1, packed2, @qd_count, @an_count, @ns_count, @ar_count]

    header_fields
      .pack("S>CCS>S>S>S>")
  end

  def self.from_bytes(unpacker)
    id = unpacker.read_int16
    packed1 = unpacker.read_byte
    packed2 = unpacker.read_byte
    qd_count = unpacker.read_int16
    an_count = unpacker.read_int16
    ns_count = unpacker.read_int16
    ar_count = unpacker.read_int16

    qr = packed1 >> 7 & 1
    op_code = packed1 >> 3 & 15
    aa = packed1 >> 2 & 3
    tc = packed1 >> 1 & 1
    rd = packed1 & 1
    ra = packed2 >> 7 & 1
    z = packed2 >> 4 & 7
    r_code = packed2 & 1

    Header.new(id, qr, op_code, tc, rd, ra, r_code, qd_count, an_count, ns_count, ar_count)
  end

  def success?
    @r_code == R_CODE_SUCCESS
  end
end