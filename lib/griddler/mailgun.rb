require 'griddler'
require 'griddler/mailgun/version'
require 'griddler/mailgun/adapter'

module Griddler
  module Mailgun
  end

  # open class for some function
  class Email
    def content_ids
      @params[:content_ids].presence || []
    end
  end
end

Griddler.adapter_registry.register(:mailgun, Griddler::Mailgun::Adapter)