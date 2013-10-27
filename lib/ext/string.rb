class String
  def cap_first
    self[0].chr.capitalize + self[1, size]
  end

  def cap_first!
    unless self[0] == (c = self[0,1].upcase[0])
      self[0] = c
      self
    end
  end
end

