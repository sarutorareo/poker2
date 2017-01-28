class BloadcastMessageJob < ApplicationJob
  queue_as :default

  def perform(message)
    # Do something later
    ActionCable.server.broadcast "room_channel_#{message.room_id}", {type: "text_message", DOM_message: render_message(message)}
  end

  private
    def render_message(message)
      ApplicationController.renderer.render(partial: 'messages/message', locals: { message: message })
    end
end
