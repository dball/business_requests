require 'active_support/core_ext/object/blank'
require_relative 'transaction'
require_relative 'state_error'

# Erases blog posts
class ErasesBlogPost
  def call(params)
    title = params.fetch(:title)
    posts_to_delete = $blog.select { |post| post.fetch(:title) == title }
    if posts_to_delete.empty?
      raise ArgumentError, "No matching post found"
    end
    unless posts_to_delete.length == 1
      raise StateError, "Too many matching posts found: blog is corrupted"
    end
    post = posts_to_delete.first
    $blog.delete(post)
    transaction = Transaction.new(post)
    $transactions << transaction
    transaction
  end

  def undo(transaction)
    performed = $transactions.delete(transaction)
    unless performed
      raise ArgumentError, "Transaction has never been performed"
    end
    post_to_restore = transaction.args.first
    colliding_post = $blog.detect { |post|
      post.fetch(:title) == post_to_restore.fetch(:title)
    }
    if colliding_post
      raise StateError, "Cannot restore blog post: title must be unique"
    end
    $blog << post_to_restore
    transaction
  end
end
