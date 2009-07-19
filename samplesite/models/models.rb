class Array
  def to_s
    self.to_sentence
  end
end

class Model
  def modelname
    self.class.lowercase 
  end
  def self.from_array(ary)
    return ary.map do |t|
      self.new(t)
    end
  end
end

class Daterange < Model
  attr_accessor :start, :end

  def initialize(d)
    if d.class == Hash
      @start = d['start']
      @end = d['end']
    else
      @start = d
      @end = nil
    end
  end

  def to_s(format="%F")
    if self.end 
      return(self.start.strftime(format) + " - " + self.end.strftime(format))
    else
      return self.start.strftime(format)
    end
  end

  def <=>(b)
    if self.end && b.end
       [self.start, self.end] <=> [b.start, b.end]
    else
       self.start <=> b.start
    end 
  end

end

class Event < Model
  attr_accessor :title, :date, :speaker

  def initialize(e)
    @title = e['title']
    @date = Daterange.new(e['date'])
    @speaker = e['speaker']
  end
end

