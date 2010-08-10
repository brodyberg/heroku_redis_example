class Trogdor
  @queue = :countryside
  
  def perform(target)
    puts "Burninating the #{target}!"
  end
end