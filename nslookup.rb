require 'socket'
require 'timeout'
require 'ap'
require_relative './unpacker.rb'
require_relative './header.rb'
require_relative './message.rb'
require_relative './question.rb'

def make_query(domain_name, dns_server)
  header = Header.new(1, Header::QR_QUERY, Header::OP_CODE_QUERY, 0, 0, 0, Header::R_CODE_SUCCESS, 1, 0, 0, 0)
  question = Question.new(domain_name, 1, Question::Q_CLASS_INTERNET)
  message = Message.new(header, [question])

  socket = UDPSocket.new
  socket.connect(dns_server, 53)
  socket.send(message.to_bytes, 0)

  response = socket.recvfrom(1000)

  Message.from_bytes(Unpacker.new(response[0]))
end

def recursive_query(domain_name, dns_server)
  message = make_query(domain_name, dns_server)
  puts "Trying ns #{dns_server}"

  message.report_message_failure

  if message.an_records.any?
    return unpack_record(message.an_records.first)
  end

  ns_addresses = message.ar_records.map do |record|
    unpack_record(record)
  end

  # p message
  puts "ns #{dns_server} didn't have record, but returned ns servers #{ns_addresses}"
  ns_addresses.each do |ns_address|
    ip = recursive_query(domain_name, ns_address)
    return ip if ip
  end
end

def unpack_record(record)
  record.rdata.unpack("CCCC").join(".")
end

puts recursive_query(ARGV[0], ARGV[1])

