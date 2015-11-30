class Message
  def initialize(header, question)
    @header = header
    @question = question
  end

  def to_bytes
    @header.to_bytes + @question.to_bytes
  end
end