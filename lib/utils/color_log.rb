#ColorLog
module ColorLog
  def self.clog (obj)
    if Rails.env == "test"
      CE.once.ch :black, :blue
      p obj
    end
    Rails.logger.debug "\e[44m#{obj.kind_of?(String) ? obj: obj.inspect}\e[0m"
  end
end
