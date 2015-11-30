require_relative "./question.rb"
require_relative "./resource_record.rb"

class Message
  attr_reader :header, :questions, :an_records
  def initialize(header, questions, an_records=[])
    @header = header
    @questions = questions
    @an_records = an_records
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

    an_records = []
    header.an_count.times do
      an_records << ResourceRecord.from_bytes(unpacker)
    end

    Message.new(header, questions, an_records)
  end

  def update_header_counts
    @header.qd_count = @questions.size
    @header.an_count = @an_records.size
  end


end