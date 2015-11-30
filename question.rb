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

  def to_bytes
    question_fields = [@q_type, @q_class]

    domain_to_q_name(@domain_name) + question_fields.pack("S>S>")
  end

  def self.from_bytes(unpacker)
    components = []
    while true
      component_length = unpacker.read_byte
      break if component_length == 0
      component = unpacker.read_string(component_length)
      components << component
    end
    domain_name = components.join(".")

    q_type, q_class = unpacker.read_int16, unpacker.read_int16

    Question.new(domain_name, q_type, q_class)
  end
end