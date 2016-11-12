#PrintUtil
module PrU
  def self.cp (obj)
    CE.once.ch :white, :blue
    if Rails.env == "test"
      p obj
    end
    Rails.logger.debug "\e[44m#{obj.kind_of?(String) ? obj: obj.inspect}\e[0m"
  end
end
