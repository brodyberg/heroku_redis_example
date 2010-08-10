class Trogdor
  @queue = :terrorize
  
  def self.perform(target)
    puts "Burninating the #{target}!"
  end
end