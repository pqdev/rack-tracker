RSpec.describe Rack::Tracker::GoogleTagManager do

  def env
    {
      misc: 'foobar',
      user_id: '123'
    }
  end

  it 'js will be placed in the head by default' do
    expect(described_class.position).to eq({ head: :prepend })
    expect(described_class.new(env).position).to eq({ head: :prepend })
    expect(described_class.new(env, position: { head: :append }).position).to eq({ head: :append })
  end
  
  it 'noscript will be placed in the body by default' do
    expect(described_class.position_ns).to eq({ body: :prepend })
    expect(described_class.new(env).position_ns).to eq({ body: :prepend })
    expect(described_class.new(env, position_ns: { body: :append }).position_ns).to eq({ body: :append })
  end

  describe "with events" do
    describe "default" do
      def env
        {'tracker' => {
          'google_tag_manager' => [
            { 'class_name' => 'Push', 'page' => 'Cart', 'price' => 50, 'content_ids' => ['sku_1', 'sku_2', 'sku_3'] }
          ]
        }}
      end

      subject { described_class.new(env, container: 'somebody').render }
      it "will show events" do
        expect(subject).to match(%r{"page":"Cart","price":50,"content_ids":\["sku_1","sku_2","sku_3"\]})
      end
    end
  end

  describe "with dynamic container" do
    subject { described_class.new(env, { container: lambda { |env| return env[:misc] }}).render }

    it 'will call container lambdas to obtain container codes' do
      expect(subject).to match(%r{\(window,document,'script','dataLayer','foobar'\)})
    end
  end

end
