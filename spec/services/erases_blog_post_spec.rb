require_relative "../../app/services/erases_blog_post"

describe ErasesBlogPost do
  before do
    $blog = []
    $transactions = []
  end
  after do
    $blog = nil
    $transactions = nil
  end

  it "erases the blog post with the given title" do
    $blog = [{ title: 'the-title', body: 'the-body' }]
    subject.call(title: 'the-title')
    $blog.should == []
  end

  it "fails to erase a blog post with no given title" do
    $blog = [{ title: 'the-title', body: 'the-body' }]
    lambda { subject.call(title: 'another-title') }.
      should raise_error(ArgumentError)
    $blog.should == [{ title: 'the-title', body: 'the-body' }]
  end

  it "undoes erasing a blog post" do
    $blog = [{ title: 'the-title', body: 'the-body' }]
    transaction = subject.call(title: 'the-title')
    subject.undo(transaction)
    $blog.should == [{ title: 'the-title', body: 'the-body' }]
  end

  it "fails to undo with an invalid transaction" do
    lambda { subject.undo('invalid-transaction') }.should
    raise_error(ArgumentError)
  end

  it "fails to undo erasing a blog post if the title is no longer unique" do
    $blog = [{ title: 'the-title', body: 'the-body' }]
    transaction = subject.call(title: 'the-title')
    $blog << { title: 'the-title', body: 'another-body' }
    lambda { subject.undo(transaction) }.should raise_error(StateError)
  end
end
