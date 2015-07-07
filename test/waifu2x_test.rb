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
      Waifu2x.convert('file.jpg', nil, { noise: 7 })
    end

    assert_raises Waifu2x::InvalidArgument do
      Waifu2x.convert('file.jpg', nil, { scale: 7 })
    end
  end

  def test_valid_image
    assert_raises(Waifu2x::InvalidImage) { Waifu2x.convert('404.jpg') }
  end
end
