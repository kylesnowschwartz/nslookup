require 'socket'
require 'ap'
require_relative './unpacker.rb'
require_relative './header.rb'
require_relative './message.rb'
require_relative './question.rb'

header = Header.new(1, Header::QR_QUERY, Header::OP_CODE_QUERY, 0, 1, 0, Header::R_CODE_SUCCESS, 1, 0, 0, 0)
question = Question.new(ARGV[0], Question::Q_TYPE_A, Question::Q_CLASS_INTERNET)
message = Message.new(header, [question])

socket = UDPSocket.new
socket.connect(ARGV[1], 53)
socket.send(message.to_bytes, 0)

response = socket.recvfrom(1000)

message = Message.from_bytes(Unpacker.new(response[0]))

puts "response: #{message.inspect}"

puts message.an_records.first.rdata.unpack("CCCC").join(".")

