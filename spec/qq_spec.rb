require 'stringio'

RSpec.describe QQ do
  it "has a version number" do
    expect(QQ::VERSION).not_to be nil
  end

  context 'default end to end' do
    it 'writes to $TMPDIR/q.log' do
      foo = "bar"

      QQ::qq(foo)
      file_contents = File.read('/tmp/q.log')
      puts "What"
      puts file_contents

      expect(file_contents).to eq("qq: foo=bar\n")
    end
  end

  context 'data structure' do
    it "includes a list of arguments with their variables" do
      first = 1
      second = 2
      third = 3

      expect(QQ::qq_generate first, second, third).to include(called_with: { first: 1, second: 2, third: 3 })
    end

    it "includes a timestamp" do
      t = Time.local(2008, 9, 1, 12, 0, 0)
      Timecop.freeze(t) do
        expect(QQ::qq_generate).to include(called_at: t)
      end
    end

    it "includes the parent function" do
      def parent
        expect(QQ::qq_generate).to include(called_from: :parent)
      end

      parent
    end
  end

  context 'formatting' do
    it "prints format to IO" do
      io = StringIO.new

      QQ::qq_io({}, io) do |generated|
        "hello"
      end

      expect(io.string).to eq("hello\n")
    end
  end

end
