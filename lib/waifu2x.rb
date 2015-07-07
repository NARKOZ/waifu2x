require 'waifu2x/version'
require 'waifu2x/errors'
require 'typhoeus'

module Waifu2x
  USER_AGENT = "Waifu2x Ruby Gem #{Waifu2x::VERSION}".freeze
  API_ENDPOINT = 'http://waifu2x.udp.jp/api'.freeze

  # Creates a new image
  #
  # @param  [String] image Image filename to convert
  # @param  [String, nil] filename Output image filename with extension
  # @param  [Hash] options
  # @option options [Integer] :noise Noise reduction (0 - none, 1 - low, 2 - high), default: 2
  # @option options [Integer] :scale Upscaling (0 - none, 1 - 1.6x, 2 - 2x), default: 0
  # @return [String] Output image filename
  def self.convert(image, filename=nil, options={})
    noise = options[:noise] || 2
    scale = options[:scale] || 0

    validate_options! noise, scale

    begin
      file = File.open(image)
    rescue
      raise InvalidImage, "Can't open image file: #{image}"
    end

    response = Typhoeus.post(API_ENDPOINT,
      headers: { 'User-Agent' => USER_AGENT },
      body: { noise: noise.to_s, scale: scale.to_s, file: file }
    )

    raise InvalidImage, response.body if response.body == 'ERROR: unsupported image format.'
    raise Waifu2x::ServerError, "Request to Waifu2x API failed with response code: #{response.code}" if response.code != 200

    filename = output_filename(file) if filename.to_s.strip.empty?

    File.write(filename, response.body)
    filename
  end

  # @private
  def self.output_filename(file)
    file_ext  = File.extname(file)
    orig_name = File.basename(file, file_ext)
    timestamp = Time.now.to_i

    "#{orig_name}_#{timestamp}#{file_ext}"
  end
  private_class_method :output_filename

  # @private
  def self.validate_options!(noise, scale)
    valid_options = [0, 1, 2]

    unless valid_options.include?(noise) && valid_options.include?(scale)
      raise InvalidArgument, 'Valid noise and scale options: 0, 1 or 2'
    end
  end
  private_class_method :validate_options!
end
