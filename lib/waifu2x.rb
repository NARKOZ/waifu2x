require 'waifu2x/version'
require 'waifu2x/errors'
require 'typhoeus'

module Waifu2x
  USER_AGENT = "Waifu2x Ruby Gem #{Waifu2x::VERSION}".freeze
  API_ENDPOINT = 'http://waifu2x.udp.jp/api'.freeze

  # Converts image from a local file or URL
  #
  # @param  [String] source Source of image to convert (url or filename)
  # @param  [String, nil] output_file Name of output image file (with extension)
  # @param  [Hash] options
  # @option options [Integer] :noise Noise reduction (0 - none, 1 - low, 2 - high), default: 2
  # @option options [Integer] :scale Upscaling (0 - none, 1 - 1.6x, 2 - 2x), default: 0
  # @option options [Boolean] :raw When true will return a converted image in raw data (binary)
  # @return [String] converted image in raw data (binary) or output filename
  def self.convert(source, output_file=nil, options={})
    noise = options[:noise] || 2
    scale = options[:scale] || 0

    validate_options! noise, scale

    if source.start_with?('http', 'ftp')
      source_params = { url: source }
    else
      begin
        source_params = { file: File.open(source) }
      rescue
        raise InvalidImage, "Can't open image file: #{source}"
      end
    end

    response = Typhoeus.post(API_ENDPOINT,
      headers: { 'User-Agent' => USER_AGENT },
      body: { noise: noise, scale: scale }.merge(source_params)
    )

    raise InvalidImage, response.body if response.body.include?('ERROR')
    raise Waifu2x::ServerError, "Request to Waifu2x API failed with response code: #{response.code}" if response.code != 200

    if options[:raw]
      response.body
    else
      output_file = output_filename(source) if output_file.to_s.strip.empty?
      File.write(output_file, response.body)
      output_file
    end
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
