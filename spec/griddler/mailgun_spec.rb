require 'spec_helper'

describe Griddler::EmailParser do
  let(:outlook) { File.open('spec/griddler/outlook.html').read }
  let(:gmail) { File.open('spec/griddler/gmail.html').read }

  it 'outlook reply part' do
    h   = subject.extract_reply_body_html(outlook, :outlook_web)
    doc = Nokogiri::HTML.parse(h)
    # 回复区域(包含 Signature)
    expect(doc.css('#divtagdefaultwrapper').size).to eq 2
    # Signature 区域
    expect(doc.css('#Signature #divtagdefaultwrapper').size).to eq 1
    expect(doc.at_css('img')['src']).to eq 'cid:aedd9c1c-3d21-4c14-97c5-52921c77bbb5'
  end

  it 'gmail reply part' do
    h   = subject.extract_reply_body_html(gmail, :gmail)
    doc = Nokogiri::HTML.parse(h)
    expect(doc.css('.gmail_extra').size).to eq 1
    expect(doc.css('.gmail_signature').size).to eq 1
    expect(doc.at_css('img')['src']).to eq 'cid:ii_1595dc15e116b681'
  end
end