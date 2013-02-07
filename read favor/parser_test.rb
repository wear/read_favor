#
#  parser_test.rb
#  read favor
#
#  Created by konglingliang on 13-2-7.
#  Copyright 2013年 konglingliang. All rights reserved.
#

require "test_helper"
require 'Parser'

class Parser
  #　修改为读取本地文件方便测试
  def fetch_data
    @parser.initWithContentsOfURL NSURL.fileURLWithPath(@feed_url)
    @parser.delegate = self   
    @parser.parse    
  end
end

class TestFeed
  attr_accessor :url
  def initialize(options={})
    @url = options[:url]
  end

  def title
    case @url 
    when 'dapengti.xml'
      '喷嚏网----阅读、发现和分享：8小时外的健康生活！'
    when 'ruan.xml'
      '阮一峰的网络日志' 
    end
  end

end

class TestPost
  attr_accessor :feed
  def initialize(options={})
    @feed = options[:feed]
  end

  def title
    case @feed.url 
    when 'dapengti.xml'
      '视频--瘟疫求生指南'
    when 'ruan.xml'
      '代码的抽象三原则' 
    end
  end

  def body
    case @feed.url 
    when 'dapengti.xml'
      '求生指南内容'
    when 'ruan.xml'
      '三原则内容' 
    end
  end
end

describe Parser do
  describe 'add feed' do
    before do
      @parser = Parser.new
    end

    describe 'get dapengti' do
      before do
        @xml_list = ['dapengti.xml','ruan.xml']
      end
      it 'should set feed info' do
        @xml_list.each do |xml_name|
          @parser.fetch_feed_data :feed_url => xml_name
          @parser.feed[:url].must_equal xml_name
          @parser.feed[:title].must_equal TestFeed.new(url:xml_name).title
        end
      end

      it 'should find one post by fetch' do
        @xml_list.each do |xml_name|
          feed = TestFeed.new(url:xml_name)
          post = TestPost.new(feed:feed)
          @parser.fetch_feed_data :feed_url => xml_name
          @parser.posts.size.must_equal 1
          @parser.posts.first[:title].must_equal post.title
          @parser.posts.first[:body].must_equal post.body
        end
      end

      # it 'should find one post in dapengti by update' do
      #   @test_feed = TestFeed.new(url:'dapengti.xml')
      #    @parser.update_feed_data :feed => @test_feed
      #   @parser.posts.size.must_equal 1
      #   @parser.posts.first[:title].must_equal 'title'
      #   @parser.posts.first[:body].must_equal 'body'
      # end
    end

  end 



end