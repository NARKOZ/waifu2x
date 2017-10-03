require 'waifu2x/version'
require 'waifu2x/errors'
require 'open-uri'
require 'typhoeus'

module Waifu2x
  USER_AGENT = "Waifu2x Ruby Gem #{Waifu2x::VERSION}".freeze
  API_ENDPOINT = 'https://waifu2x.booru.pics'.freeze

  # Converts image from a local file or remote URL
  #
  # @param  [String] source Source of image to convert (url or filename)
  # @param  [String, nil] output_file Filename of the converted image file (with extension)
  # @param  [Hash] options
  # @option options [Integer] :noise Noise reduction (0 - none, 1 - medium, 2 - high), default: 1
  # @option options [Integer] :scale Upscaling (1 - none, 2 - 2x), default: 2
  # @option options [Boolean] :raw When true will return URL of the converted image
  # @return [String] converted image URL or filename
  def self.convert(source, output_file=nil, options={})
    if source =~ /\A(https?|ftp):\/\//i
      converted_url = handle_request(source, options)
    else
      begin
        converted_url = handle_request(File.open(source), options)
      rescue Errno::ENOENT, Errno::EACCES
        raise InvalidImage, "Can't open image file: #{source}"
      end
    end

    if options[:raw]
      converted_url
    else
      output_file = output_filename(source) if output_file.to_s.strip.empty?
      IO.copy_stream(open(converted_url), output_file)
      output_file
    end
  end

  # Performs request to the Waifu2x API for image conversion
  #
  # @param  [File, String] Image file or URL of an image to convert
  # @param  [Hash] options
  # @option options [Integer] :noise Noise reduction (0 - none, 1 - medium, 2 - high), default: 1
  # @option options [Integer] :scale Upscaling (1 - none, 2 - 2x), default: 2
  # @return [String] converted image URL
  def self.handle_request(file_or_url, options)
    noise = options[:noise] || 1
    scale = options[:scale] || 2

    validate_options! noise, scale

    default_request_options = {
      followlocation: true,
      headers: { 'User-Agent' => USER_AGENT }
    }

    request = if file_or_url.is_a?(File)
                Typhoeus::Request.new(
                  "#{API_ENDPOINT}/Home/upload",
                  default_request_options.merge(
                    method: :post,
                    body: { denoise: noise, scale: scale, img: file_or_url }
                  )
                )
              else
                Typhoeus::Request.new(
                  "#{API_ENDPOINT}/Home/fromlink",
                  default_request_options.merge(
                    method: :get,
                    params: { denoise: noise, scale: scale, url: file_or_url }
                  )
                )
              end
    response = request.run

    if response.body.include?('File not found') ||
       response.body.include?('Image file is not of type') ||
       response.body.include?('Image file is too large')
      raise InvalidImage, response.body
    end

    if response.code != 200
      raise Waifu2x::ServerError, "Request to Waifu2x API failed with response code: #{response.code}"
    end

    hash = response.effective_url.match(/hash=(\S+)/)[1]
    "#{API_ENDPOINT}/outfiles/#{hash}.jpg"
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
