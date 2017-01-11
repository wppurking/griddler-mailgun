module Griddler
  module Mailgun
    class Adapter
      attr_reader :params

      def initialize(params)
        @params = params
      end

      def self.normalize_params(params)
        adapter = new(params)
        adapter.normalize_params
      end

      def normalize_params
        {
          to:          to_recipients,
          cc:          cc_recipients,
          bcc:         Array.wrap(param_or_header(:Bcc)),
          from:        determine_sender,
          forwards:    determine_forwards,
          subject:     params[:subject],
          text:        params['body-plain'],
          html:        params['body-html'],
          attachments: attachment_files,
          headers:     headers,
          content_ids: content_id_map
        }
      end

      private

      def determine_sender
        sender = param_or_header(:From)
        sender ||= params[:sender]
      end

      def determine_forwards
        forwards = param_or_header(:'X-Forwarded-To')
        forwards ? forwards.split(',').map(&:strip) : []
      end

      def to_recipients
        to_emails = param_or_header(:To)
        to_emails ||= params[:recipient]
        to_emails.split(',').map(&:strip)
      end

      def cc_recipients
        cc = param_or_header(:Cc) || ''
        cc.split(',').map(&:strip)
      end

      def headers
        @headers ||= extract_headers
      end

      def extract_headers
        extracted_headers = {}
        if params['message-headers']
          parsed_headers = JSON.parse(params['message-headers'])
          parsed_headers.each { |h| extracted_headers[h[0]] = h[1] }
        end
        ActiveSupport::HashWithIndifferentAccess.new(extracted_headers)
      end

      def param_or_header(key)
        if params[key].present?
          params[key]
        elsif headers[key].present?
          headers[key]
        else
          nil
        end
      end

      # content_id_map 与 attachment_files 的数量一致. 索引位置一致, 用于获取 content_id
      def content_id_map
        if params["attachment-count"].present? && params['content-id-map'].present?
          attachment_count = params["attachment-count"].to_i
          id_map           = JSON.parse(params['content-id-map'])
          attachment_count.times.map do |index|
            id_map.key("attachment-#{index+1}")
          end
        else
          []
        end
      end

      def attachment_files
        if params["attachment-count"].present?
          attachment_count = params["attachment-count"].to_i

          attachment_count.times.map do |index|
            params.delete("attachment-#{index+1}")
          end
        else
          params["attachments"] || []
        end
      end
    end
  end
end
