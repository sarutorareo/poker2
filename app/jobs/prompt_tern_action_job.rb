class PromptTernActionJob < ApplicationJob
  queue_as :default

  def perform(room_id, user)
    PrU.cp "###### in #{self.class} perform user_id=#{user.id} room_id=#{room_id}"
    #TODO ユーザーが人間なら手番を伝えるメッセージを送る
    #TODO ユーザーがCPUならactionを決定してchannelのtern_actionを呼び出させる
  end
end

