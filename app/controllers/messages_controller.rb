class MessagesController < ApplicationController
  before_action :authenticate_user!

  def new
      @message = Message.new
  end

  def create
    @chat = Chat.find_or_create_by(id: params[:chat_id])
    @message = @chat.messages.create(message_params.merge(role: "user"))

    GetAiResponse.perform_async(@message.chat_id)

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
