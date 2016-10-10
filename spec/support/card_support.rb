module CardSupport
  def self.comp_card_list_order(list1, list2)
    (0..list1.count-1).each do |idx| 
      suit1 = list1[idx].suit
      suit2 = list2[idx].suit
      no1 = list1[idx].no
      no2 = list2[idx].no
      return false if suit1 != suit2
      return false if no1 != no2
    end
    return true
  end
end
