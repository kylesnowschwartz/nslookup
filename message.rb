require_relative "./question.rb"
require_relative "./resource_record.rb"

class Message
  attr_reader :header, :questions, :an_records, :ar_records
  def initialize(header, questions, an_records=[], ar_records=[], ns_records=[])
    @header = header
    @questions = questions
    @an_records = an_records
    @ar_records = ar_records
    @ns_records = ns_records
  end

  def to_bytes
    update_header_counts
    @header.to_bytes + @questions.map(&:to_bytes).join
  end

  def self.from_bytes(unpacker)
    header = Header.from_bytes(unpacker)

    questions = []
    header.qd_count.times do
      questions << Question.from_bytes(unpacker)
    end

    an_records = read_records(header.an_count, unpacker)
    ns_records = read_records(header.ns_count, unpacker)
    ar_records = read_records(header.ar_count, unpacker)

    Message.new(header, questions, an_records, ar_records, ns_records)
  end

  def self.read_records(count, unpacker)
    records = []

    count.times do
      records << ResourceRecord.from_bytes(unpacker)
    end

    records
  end

  def update_header_counts
    @header.qd_count = @questions.size
    @header.an_count = @an_records.size
  end

  def report_message_failure
    if !@header.success?
      puts "Error communicating to ns"
      return nil
    end
  end
end