# WeeChat Self-Censor Script

Forbid the inclusion of certain text in outgoing messages.

*Note: Documentation is a bit lacking at the moment. Hang tight.*

# Usage

Simply set the appropriate options and the script will operate on its own.

* `plugins.var.ruby.self-censor.censored_buffers` - Comma-separated list of
  buffers in which to apply censorship. Wildcards are supported. Start a name
  with ! to exclude.
* `plugins.var.ruby.self-censor.forbidden_words` - Comma-separated list of
  words to forbid in outgoing messages. Wildcards are supported.
* `plugins.var.ruby.self-censor.forbidden_word_color` - Color of forbidden
  words in output.

**Important:** Only `/\w+/` is checked while scanning for forbidden words. This
means that you cannot include punctuation or spaces in the words you forbid.
This limitation *may* be removed in future versions.

