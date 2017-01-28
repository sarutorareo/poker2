class BroadcastPotsJob < ApplicationJob
  queue_as :default

  def perform(room_id, serialized_pots)
    pots = Marshal.load(serialized_pots)
    ActionCable.server.broadcast "poker_channel_#{room_id}", {type: "msg_update_pots", DOM_pots: render_pots(pots)}
  end

  private
  def render_pots(pots)
    ApplicationController.renderer.render(partial: 'hand/pots', locals: { pots: pots })
  end
end
