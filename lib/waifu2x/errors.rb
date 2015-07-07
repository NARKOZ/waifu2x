module Waifu2x
  # Custom error class for rescuing from all Waifu2x errors.
  class Error < StandardError; end

  # Raised when invalid image file is passed.
  class InvalidImage < Error; end

  # Raised when invalid option is passed.
  class InvalidArgument < Error; end

  # Raised when Waifu2x API server doesn't return the HTTP status code 200 (OK).
  class ServerError < Error; end
end
