class GetAiResponse
  include Sidekiq::Worker
  RESPONSES_PER_MESSAGE = 1
  MODEL_NAME = "gpt-3.5-turbo"
  TEMPERATURE = 0.8

  def perform(chat_id)
    chat = Chat.find(chat_id)
    call_openai(chat)
  end

  private

  def call_openai(chat)
    OpenAI::Client.new.chat(
      parameters: {
        model: MODEL_NAME,
        messages: Message.for_openai(chat.messages),
        temperature: TEMPERATURE,
        stream: stream_proc(chat),
        n: RESPONSES_PER_MESSAGE
      }
    )
  end

  response = OpenAI::Client.new.chat(
    parameters: {
        model: "gpt-3.5-turbo", # Required.
        messages: [{ role: "user", content: "Hello!"}], # Required.
        temperature: 0.7,
    })
# => "Hello! How may I assist you today?"

  def create_messages(chat)
    Array.new(RESPONSES_PER_MESSAGE) do |i|
      message = chat.messages.create(role: "assistant", content: "", response_number: i)
      message.broadcast_created
      message
    end
  end

  def stream_proc(chat)
    messages = create_messages(chat)
    proc do |chunk, _bytesize|
      new_content = chunk.dig("choices", 0, "delta", "content")
      message = messages.find { |m| m.response_number == chunk.dig("choices", 0, "index") }
      message.update(content: message.content + new_content) if new_content
    end
  end
end
