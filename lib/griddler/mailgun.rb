require 'griddler'
require 'griddler/mailgun/version'
require 'griddler/mailgun/adapter'

Griddler.adapter_registry.register(:mailgun, Griddler::Mailgun::Adapter)