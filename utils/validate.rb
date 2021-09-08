# frozen_string_literal: true

# library imports
require 'uri'

def valid_url(url)
    url =~ /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/
end
