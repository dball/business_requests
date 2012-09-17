# Entity class modeling a business transaction
class Transaction
  attr_reader :args

  def initialize(*args)
    @args = args
  end
end
