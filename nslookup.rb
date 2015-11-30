require 'socket'
require_relative './unpacker.rb'
require_relative './header.rb'
require_relative './message.rb'
require_relative './question.rb'

header = Header.new(1, Header::QR_QUERY, Header::OP_CODE_QUERY, 0, 1, 0, Header::R_CODE_SUCCESS, 1, 0, 0, 0)

question = Question.new("powershop.co.nz", Question::Q_TYPE_NAME, Question::Q_CLASS_INTERNET)

message = Message.new(header, question)

# puts message.to_bytes.inspect

socket = UDPSocket.new

socket.connect("8.8.8.8", 53)

bytes_send = socket.send(message.to_bytes, 0)

p "bytes sent: #{bytes_send}"

response = socket.recvfrom(1000)

response_header = Header.from_bytes(Unpacker.new(response[0]))

p "response header: #{response_header.inspect}"
p "message: #{response[0]}"
p "sender: #{response[1]}"

