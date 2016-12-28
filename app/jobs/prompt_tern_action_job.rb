class PromptTernActionJob < ApplicationJob
  queue_as :default

  def perform(room_id, user)
    #TODO ユーザーが人間なら手番を伝えるメッセージを送る
    #TODO ユーザーがCPUならactionを決定してchannelのtern_actionを呼び出させる
  end
end

