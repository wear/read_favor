#
#  Parser.rb
#  read favor
#
#  Created by konglingliang on 13-2-4.
#  Copyright 2013年 konglingliang. All rights reserved.
#

require 'Date'

class Parser
  attr_accessor :feed,:posts,:post

  def initialize
    @posts = []
    @parser = NSXMLParser.alloc.init
    # tag标记
    @post_mark_tags = ['entry','item']
    @post_pubdate_tags = ['published','pubDate']
    @post_body_tags = ['content','description']
  end

  def fetch_feed_data(params={})
    @feed = {}
    @need_create_feed = true 
    @feed_url = params[:feed_url]
    fetch_data
  end

  def update_feed_data(params={})
    @feed = params[:feed]
    @need_create_feed = false
    @feed_url = @feed.url
    fetch_data
  end

  def fetch_data
    @parser.initWithContentsOfURL NSURL.URLWithString @feed_url
    @parser.delegate = self   
    @parser.parse    
  end

  # 代理方法实现
  def parserDidStartDocument(parser)
    # puts '开始解析文档'
  end

  def parserDidEndDocument(parser)
    # 重设
  end

  def parser parser,didStartElement:el,namespaceURI:namespace,qualifiedName:qua_nameame,attributes:attr
    @post = {} if @post_mark_tags.include? el
  end

  def parser parser,foundCharacters:found_chars
    @current_founded_string = found_chars
  end

  def parser parser,foundCDATA:cdata_block
    @currentCDATAString ||= NSMutableString.alloc.init
    someString = NSString.alloc.initWithData cdata_block,encoding:NSUTF8StringEncoding
    @currentCDATAString.appendString someString
  end

  def parser(parser,didEndElement:el,namespaceURI:namespaceURI,qualifiedName:qName)
    if el == 'title' && !@post && @need_create_feed
      @feed[:title] = formated_title
      @feed[:url] = @feed_url
    end

    if @post
      if el == 'title'
        p formated_title
        @post[:title] = formated_title 
      end
      if @post_body_tags.include?(el)
        @post[:body] = (@currentCDATAString ? @currentCDATAString : @current_founded_string)
      end
      @post[:created_at] = DateTime.parse(@current_founded_string).to_time if @post_pubdate_tags.include? el
      @posts << @post if @post_mark_tags.include? el
    end

    @current_founded_string = nil
    @currentCDATAString = nil
  end

  def formated_title
    if @currentCDATAString.nil? 
      @current_founded_string.stringByReplacingOccurrencesOfString("\n",withString:'').stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet)
    else
      @currentCDATAString
    end
  end

end