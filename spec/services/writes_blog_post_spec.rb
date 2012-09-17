require_relative "../../app/services/writes_blog_post"

describe WritesBlogPost do
  before do
    $blog = []
    $transactions = []
  end
  after do
    $blog = nil
    $transactions = nil
  end

  it "writes a blog post" do
    subject.call(title: 'the-title', body: 'the-body')
    $blog.should == [{ title: 'the-title', body: 'the-body' }]
  end

  it "fails to write without a title" do
    lambda { subject.call(title: '', body: 'the-body') }.
      should raise_error(ArgumentError)
    $blog.should == []
  end

  it "fails to write without a unique title" do
    $blog << { title: 'the-title', body: 'the-body' }
    lambda { subject.call(title: 'the-title', body: 'another-body') }.
      should raise_error(ArgumentError)
    $blog.should == [{ title: 'the-title', body: 'the-body' }]
  end

  it "undos writing a blog post" do
    transaction = subject.call(title: 'the-title', body: 'the-body')
    subject.undo(transaction)
    $blog.should == []
  end

  it "fails to undo writing a blog post with an invalid transaction" do
    lambda { subject.undo('invalid-transaction') }.
      should raise_error(ArgumentError)
  end

  it "fails to undo writing a blog post if the post is already deleted" do
    transaction = subject.call(title: 'the-title', body: 'the-body')
    $blog.clear
    lambda { subject.undo(transaction) }.should raise_error(StateError)
  end
end
