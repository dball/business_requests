require 'active_support/core_ext/object/blank'
require_relative 'transaction'
require_relative 'state_error'

# Writes blog posts
class WritesBlogPost
  def call(params)
    title = params.fetch(:title) { '' }
    body = params.fetch(:body) { '' }
    unless title.present?
      raise ArgumentError, "Title must be present"
    end
    if $blog.detect { |post| post.fetch(:title) == title }
      raise ArgumentError, "Title must be unique"
    end
    post = { title: title, body: body }
    $blog << post
    transaction = Transaction.new(post)
    $transactions << transaction
    transaction
  end

  def undo(transaction)
    performed = $transactions.delete(transaction)
    unless performed
      raise ArgumentError, "Transaction has never been performed"
    end
    deleted = $blog.delete(performed.args.first)
    unless deleted
      raise StateError, "Blog post was already deleted"
    end
    transaction
  end
end
