require 'socket'

class Header
  OP_CODE_QUERY = 0
  OP_CODE_IQUERY = 1
  OP_CODE_STATUS = 2

  QR_QUERY = 0
  QR_RESPONSE = 1

  R_CODE_SUCCESS = 0


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

  def as_bytes
    packed1 = @qr << 7 | @op_code << 3 | @aa << 2 | @tc << 1 | @rd
    packed2 = @ra << 7 | @z << 4 |@r_code
    header_fields = [@id, packed1, packed2, @qd_count, @an_count, @ns_count, @ar_count]

    header_fields
      .pack("S>CCS>S>S>S>")
  end

  def self.from_bytes(message)
    id, packed1, packed2, qd_count, an_count, ns_count, ar_count = message.unpack("S>CCS>S>S>S>")
    qr = packed1 >> 7 & 1
    op_code = packed1 >> 3 & 15
    aa = packed1 >> 2 & 3
    tc = packed1 >> 1 & 1
    rd = packed1 & 1
    ra = packed2 >> 7 & 1
    z = packed2 >> 4 & 7
    r_code = packed2 & 1

    [Header.new(id, qr, op_code, tc, rd, ra, r_code, qd_count, an_count, ns_count, ar_count), 12]
  end
end

class Question
  Q_TYPE_NAME = 2
  Q_CLASS_INTERNET = 1

  def initialize(domain_name, q_type, q_class)
    @domain_name = domain_name
    @q_type = q_type
    @q_class = q_class
  end

  def domain_to_q_name(domain_name)
    name_components = domain_name.split(".")

    name_components.map do |component|
      [component.size].pack("C") + component
    end.join + "\0"
  end

  def as_bytes
    question_fields = [@q_type, @q_class]

    domain_to_q_name(@domain_name) + question_fields.pack("S>S>")
  end

  def self.from_bytes(message)
    offset = 0
    components = []
    while true
      component_length, offset = read_byte(message, offset)
      break if component_length == 0
      component, offset = read_string(message, offset, component_length)
      puts component.inspect
      components << component
    end
    domain_name = components.join(".")

    q_type, q_class = message[offset..-1].unpack("S>S>")
    offset += 4

    question = Question.new(domain_name, q_type, q_class)

    [question, offset]
  end

  def self.read_byte(message, offset)
    [message[offset..offset].unpack("C")[0], offset + 1]
  end

  def self.read_string(message, offset, length)
    puts "offset #{offset} length #{length}"
    [message[offset..(offset + length -1)], offset + length]
  end
end

class Message
  def initialize(header, question)
    @header = header
    @question = question
  end

  def as_bytes
    @header.as_bytes + @question.as_bytes
  end
end

header = Header.new(1, Header::QR_QUERY, Header::OP_CODE_QUERY, 0, 1, 0, Header::R_CODE_SUCCESS, 1, 0, 0, 0)

question = Question.new("powershop.co.nz", Question::Q_TYPE_NAME, Question::Q_CLASS_INTERNET)

new_question = Question.from_bytes(question.as_bytes)

puts "old #{question.inspect}"
puts "new #{new_question.inspect}"

message = Message.new(header, question)

# puts message.as_bytes.inspect

socket = UDPSocket.new

socket.connect("8.8.8.8", 53)

bytes_send = socket.send(message.as_bytes, 0)

p "bytes sent: #{bytes_send}"

response = socket.recvfrom(1000)

response_header = Header.from_bytes(response[0])

p "response header: #{response_header.inspect}"
p "message: #{response[0]}"
p "sender: #{response[1]}"

