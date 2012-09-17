require 'active_support/core_ext/object/blank'

class WritesBlogPost
  def initialize
    $blog ||= []
    $transactions ||= []
  end

  def call(params)
    title = params.fetch(:title) { '' }
    body = params.fetch(:body) { '' }
    unless title.present?
      raise ArgumentError, "Title must be present"
    end
    post = BlogPost.new(title, body)
    $blog << post
    transaction = Transaction.new(post)
    $transactions << transaction
    transaction
  end

  def undo(transaction)
    performed = $transactions.delete(transaction)
    raise ArgumentError unless performed
    deleted = $blog.delete(performed.args.first)
    raise StateError unless deleted
    transaction
  end

  class BlogPost < Struct.new(:title, :body)
  end

  class Transaction
    attr_reader :args

    def initialize(*args)
      @args = args
    end
  end
end

class StateError < StandardError
end
