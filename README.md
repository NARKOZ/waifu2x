# Waifu2x

Ruby wrapper and CLI for waifu2x.  
Noise Reduction and 2x Upscaling for anime style images.

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
Waifu2x.convert('image.png', nil, { scale: 2 })
Waifu2x.convert('image.png', 'converted.png', { noise: 0, scale: 2 })
```

## CLI usage

```sh
waifu2x sample.jpg -s 2
waifu2x sample.jpg output.jpg -n 0 -s 2
```

## License

Released under the BSD 2-clause license. See LICENSE.txt for details.
