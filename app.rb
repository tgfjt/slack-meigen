# coding: utf-8

require 'bundler/setup'
require 'open-uri'
require 'httpclient'
require 'json'
require 'nokogiri'
require 'clockwork'

def payload(title, message, source)
  {
    text: "#{message} ... From #{source}",
    channel: "#{ENV['SLACK_CHANNNEL']}",
    icon_emoji: "#{ENV['SLACK_ICON']}",
    username: "【#{title}】"
  }
end

def meigen_job
  url = 'http://www.iwanami.co.jp/meigen/heute.html'
  api = "https://#{ENV['SLACK_TEAM']}.slack.com/services/hooks/incoming-webhook?token=#{ENV['SLACK_TOKEN']}"
  html = open(url).read

  doc = Nokogiri::HTML.parse(html, nil)

  title = doc.title
  message = doc.xpath('//div[@class="witticism"]').text
  source = doc.xpath('//div[@class="source"]/a').text

  data = JSON.generate(payload(title, message, source))

  http_client = HTTPClient.new
  http_client.post_content(api, data, 'Content-Type' => 'application/json')
end

module Clockwork
  handler do |job|
    case job
    when 'halfday.job'
      meigen_job
    end
  end

  every(12.hour, 'halfday.job')
end
