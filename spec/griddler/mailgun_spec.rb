require 'spec_helper'

describe Griddler::EmailParser do
  let(:outlook) { File.open('spec/griddler/outlook.html').read }

  context 'outlook' do
    it 'html' do
      h   = subject.extract_reply_body_html(outlook, :outlook_web)
      doc = Nokogiri::HTML.parse(h)
      # 回复区域(包含 Signature)
      expect(doc.css('#divtagdefaultwrapper').size).to eq 2
      # Signature 区域
      expect(doc.css('#Signature #divtagdefaultwrapper').size).to eq 1
      expect(doc.at_css('img')['src']).to eq 'cid:aedd9c1c-3d21-4c14-97c5-52921c77bbb5'
    end
  end
end