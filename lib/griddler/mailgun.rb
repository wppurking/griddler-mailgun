require 'griddler'
require 'griddler/mailgun/version'
require 'griddler/mailgun/adapter'

module Griddler
  module Mailgun
  end

  # open class for some function
  class Email
    CLIENT_PATTERNS = {
      # outlook web
      outlook_web: /prod\.outlook\.com/,
      gmail:       /mail\.gmail\.com/,
      icloud:      /icloud\.com/
    }

    def content_ids
      @params[:content_ids].presence || []
    end

    def email_client
      message_id = headers['Message-Id']
      CLIENT_PATTERNS.each do |client, pattern|
        return client if message_id.match?(pattern)
      end
    end

    # 改写原有的 extract_body 方法, 在这里处理 html 与 body 的不同的截取处理.
    # 1. html 的方法为只切取自定义的 <blockquote> 标签
    # 2. text 的处理, 走默认方法
    def extract_body
      html = sanitize(params.fetch(:html, ''), attributes: ['src', 'id'])
      if html.present?
        EmailParser.extract_reply_body_html(html, client)
      else
        EmailParser.extract_reply_body(text_or_sanitized_html)
      end
    end
  end


  module EmailParser
    # html: html 的内容
    # client: 是哪一个 email client
    def self.extract_reply_body_html(html, client)
      doc = Nokogiri::HTML.parse(html)
      case client
      when :outlook_web
        doc.at_css('body > #divtagdefaultwrapper').to_s
      when :gmail
        doc.at_css('body > .gmail_extra > .gmail_quote').remove
        doc.at_css('body').inner_html
      when :icloud
        doc.at_css('body > div > blockquote[type=cite]').remove
        doc.at_css('body').inner_html
      end
    end
  end

end

Griddler.adapter_registry.register(:mailgun, Griddler::Mailgun::Adapter)