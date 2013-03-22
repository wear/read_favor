#
#  parser_test.rb
#  read favor
#
#  Created by konglingliang on 13-2-7.
#  Copyright 2013年 konglingliang. All rights reserved.
#

require "test_helper"
require 'Parser'

# class Parser
#   def formatted_data
#     url = NSURL.URLWithString(@feed_url)
#     error = Pointer.new_with_type("@")
#     feed_str = NSString.stringWithContentsOfFile url,encoding:NSUTF8StringEncoding,error:error
#     feed_data = feed_str.dataUsingEncoding NSUTF8StringEncoding
#   end
# end

describe Parser do
  describe 'add feed' do
    before do
      @parser = Parser.new
    end

    describe 'get dapengti' do
      before do
        @parser.expects(:get_feed_string).returns NSString.stringWithContentsOfFile('dapengti.xml',encoding:NSUTF8StringEncoding,error:nil)
      end

      it 'should set feed info' do
        @parser.fetch_feed_data :feed_url => 'dapengti.xml'
        @parser.feed[:url].must_equal 'dapengti.xml'
        @parser.feed[:title].must_equal '喷嚏网----阅读、发现和分享：8小时外的健康生活！'
      end

      it 'should find one post by fetch' do
        @parser.fetch_feed_data :feed_url => 'dapengti.xml'
        @parser.posts.size.must_equal 1
        @parser.posts.first[:title].must_equal '视频--瘟疫求生指南'
        @parser.posts.first[:body].must_equal '求生指南内容'
        # @parser.posts.first[:link].must_equal post.link
      end

      it 'should find one post in dapengti by update' do
        feed = mock()
        feed.expects(:url).returns('dapengti.xml')

        @parser.update_feed_data(:feed => feed)
        @parser.posts.size.must_equal 1
        @parser.posts.first[:title].must_equal'视频--瘟疫求生指南'
        @parser.posts.first[:body].must_equal '求生指南内容'
      end
    end

    describe 'get ruan' do
      before do 
        @parser.expects(:get_feed_string).returns NSString.stringWithContentsOfFile('ruan.xml',encoding:NSUTF8StringEncoding,error:nil)
        # @parser.expects(:formatted_url).returns NSURL.fileURLWithPath('ruan.xml')
      end

      it 'should set feed info' do
        @parser.fetch_feed_data :feed_url => 'ruan.xml'
        @parser.feed[:url].must_equal 'ruan.xml'
        @parser.feed[:title].must_equal '阮一峰的网络日志' 
      end

      it 'should find one post by fetch' do
        @parser.fetch_feed_data :feed_url => 'ruan.xml'
        @parser.posts.size.must_equal 1
        @parser.posts.first[:title].must_equal '代码的抽象三原则'
        @parser.posts.first[:body].must_equal '三原则内容' 
        @parser.posts.first[:link].must_equal 'http://www.ruanyifeng.com/blog/2013/01/abstraction_principles.html'
      end
    end

    describe 'get 36kr' do
      before do 
        @parser.expects(:get_feed_string).returns NSString.stringWithContentsOfFile('36kr.xml',encoding:NSUTF8StringEncoding,error:nil)
        # @parser.expects(:formatted_url).returns NSURL.fileURLWithPath('36kr.xml')
      end

      it 'should set feed info' do
        @parser.fetch_feed_data :feed_url => '36kr.xml'
        @parser.feed[:url].must_equal '36kr.xml'
        @parser.feed[:title].must_equal '36氪' 
      end

      it 'should find one post by fetch' do
        @parser.fetch_feed_data :feed_url => '36kr.xml'
        @parser.posts.size.must_equal 1
        @parser.posts.first[:title].must_equal "Mailbox宣布完成第100万个用户的预约处理，新增“摇一摇Undo“功能"
        @parser.posts.first[:body].must_match /并且对之前的版本进行了更新/
        @parser.posts.first[:link].must_equal 'http://www.36kr.com/p/202079.html'
      end
    end



    describe 'get nbweekly' do
      before do 
        @parser.expects(:get_feed_string).returns NSString.stringWithContentsOfFile('nbweekly.xml',encoding:NSUTF8StringEncoding,error:nil)
        # @parser.expects(:formatted_url).returns NSURL.fileURLWithPath('36kr.xml')
      end

      it 'should set feed info' do
        @parser.fetch_feed_data :feed_url => 'nbweekly.xml'
        @parser.feed[:url].must_equal 'nbweekly.xml'
        @parser.feed[:title].must_equal '南都周刊' 
      end

      it 'should find one post by fetch' do
        @parser.fetch_feed_data :feed_url => 'nbweekly.xml'
        @parser.posts.size.must_equal 1
        @parser.posts.first[:title].must_equal '张铁志：公知污名化，谁受益？'
        @parser.posts.first[:body].must_match /被污名化，刘瑜说/
        @parser.posts.first[:link].must_equal "http://nbweekly.feedsportal.com/c/34905/f/643776/s/29ae8f55/l/0L0Snbweekly0N0Ccolumn0Czhangtiezhi0C20A130A20C324340Baspx/story01.htm"
      end
    end

  end 

end