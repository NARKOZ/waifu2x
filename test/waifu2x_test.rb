require 'test_helper'

class Waifu2xTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Waifu2x::VERSION
  end

  def test_that_it_has_a_convert_method
    assert_respond_to Waifu2x, :convert
  end

  def test_valid_options
    assert_raises Waifu2x::InvalidArgument do
      Waifu2x.convert('http://example.com/file.jpg', nil, noise: 7)
    end

    assert_raises Waifu2x::InvalidArgument do
      Waifu2x.convert('http://example.com/file.jpg', nil, scale: 7)
    end
  end

  def test_valid_image
    assert_raises(Waifu2x::InvalidImage) { Waifu2x.convert('404.jpg') }
  end

  def test_handle_request
    fixture_path = './test/fixtures/sample.png'
    fixture_url  = 'http://example.com/sample.png'
    hash = 'd3227374a6586cb78e420ae5b5f1c09d6f5a6d2d_s2_n1'
    redirected = "#{Waifu2x::API_ENDPOINT}/Home/status?handle=H%3Awaifu2x.slayerduck.com%3A1356804&hash=#{hash}"

    response = Typhoeus::Response.new(code: 200, body: File.read(fixture_path), effective_url: redirected)
    Typhoeus.stub("#{Waifu2x::API_ENDPOINT}/Home/upload").and_return(response)
    Typhoeus.stub("#{Waifu2x::API_ENDPOINT}/Home/fromlink").and_return(response)
    Typhoeus.stub(fixture_url).and_return(response)

    [fixture_path, File.open(fixture_path), fixture_url].each do |source|
      data = Waifu2x.convert(source, nil, raw: true)
      assert_equal "#{Waifu2x::API_ENDPOINT}/outfiles/#{hash}.jpg", data
    end
  end
end
