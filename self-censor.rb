# Copyright (C) 2013 Kyle Johnson <kyle@vacantminded.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.)

def weechat_init
  Weechat.register 'self-censor', 'Kabaka', '0.5', 'MIT',
    'Prevent messages from being sent when they contain certain text.', '', ''

  Weechat.hook_modifier 'input_text_for_buffer',
    'input_callback', ''

  Weechat.config_set_desc_plugin 'forbidden_words',
    ['Comma-separated list of words to forbid in outgoing messages.',
      'Wildcards are supported.'].join(' ')

  Weechat.config_set_desc_plugin 'censored_buffers',
    ['Comma-separated list of buffers in which to apply censorship.',
      'Wildcards are supported. Start a name with ! to exclude.'].join(' ')

  Weechat.config_set_desc_plugin 'forbidden_word_color',
    'Color of forbidden words in output.'

  if Weechat.config_is_set_plugin('forbidden_word_color').zero?
    Weechat.config_set_plugin 'forbidden_word_color', '*red'
  end

  Weechat::WEECHAT_RC_OK
end

def input_callback data, modifier, buffer, string
  return string if string[0] == '/' and not string.start_with? '/me '

  return string if Weechat.buffer_match_list(buffer, censored_buffers).zero?

  censor string, buffer
end

def censor string, buffer
  found = []

  forbidden = get_forbidden

  string.downcase.scan(/\w+/).each do |word|
    forbidden.each do |mask|
      next if Weechat.string_match(word, mask, 0).zero?
      
      found << word
    end
  end

  unless found.empty?
    color = Weechat.color get_forbidden_color
    reset = Weechat.color 'reset'

    found.uniq.each do |word|
      string.gsub! /\b(#{word})([^\w]|$)/,
        "#{color}\\1#{reset}\\2"
    end

    Weechat.print buffer, [
      Weechat.prefix('error'),
      [
        "Message rejected: contains forbidden word#{'s' if found.length > 1}",
        string
      ].join("\n")
    ].join

    return ''
  end

  string
end

def get_forbidden
  Weechat.config_get_plugin('forbidden_words').downcase.split(',') || []
end

def get_forbidden_color
  Weechat.config_get_plugin 'forbidden_word_color'
end

def censored_buffers
  Weechat.config_get_plugin 'censored_buffers'
end

