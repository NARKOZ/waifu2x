# Waifu2x [![Build Status](https://travis-ci.org/NARKOZ/waifu2x.svg)](https://travis-ci.org/NARKOZ/waifu2x)

Waifu2x is a ruby wrapper and CLI for
[waifu2x](https://github.com/nagadomi/waifu2x), which provides Noise Reduction
and 2x Upscaling for anime style images.

## Installation

Install it from rubygems:

```sh
gem install waifu2x
```

Or add to your application's Gemfile:

```ruby
gem 'waifu2x'
```

and run:

```sh
bundle install
```

## Usage

```ruby
# convert image.png with 2x upscaling
Waifu2x.convert('image.png', nil, { scale: 2 })

# convert image.png from remote url
Waifu2x.convert('http://example.net/image.png', nil, { scale: 2 })

# convert image.png to converted.png without noise reduction and with 2x upscaling
Waifu2x.convert('image.png', 'converted.png', { noise: 0, scale: 2 })
```

## CLI usage

```sh
# convert sample.jpg with 2x upscaling
waifu2x sample.jpg -s 2

# convert sample.jpg from remote url
waifu2x http://example.net/sample.jpg -s 2

# convert sample.jpg to output.jpg without noise reduction and with 2x upscaling
waifu2x sample.jpg output.jpg -n 0 -s 2
```

## License

Released under the BSD 2-clause license. See LICENSE.txt for details.
