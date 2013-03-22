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

  EntryMark = ['entry','item']
  PubDateMark = ['published','pubDate']
  BodyMark = ['content','description']

  def initialize
    @parser = NSXMLParser.alloc.init
  end

  def fetch_feed_data(params={})
    @feed = {}
    @posts = []
    @need_create_feed = true 
    @feed_url = params[:feed_url]
    fetch_data
  end

  def update_feed_data(params={})
    @posts = []
    @feed = params[:feed]
    @need_create_feed = false
    @feed_url = @feed.url
    fetch_data
  end

  def get_feed_string
    url = NSURL.URLWithString(@feed_url)
    error = Pointer.new_with_type("@")
    NSString.stringWithContentsOfURL url,encoding:NSUTF8StringEncoding,error:error
  end

  def formatted_data
    feed_str =get_feed_string
    feed_str.dataUsingEncoding NSUTF8StringEncoding
  end

  def fetch_data
    @parser.initWithData formatted_data
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
    @post = {} if EntryMark.include? el
    @post[:link] = attr['href'] if el == 'link' && @post
  end

  def parser parser,foundCharacters:found_chars
    if !@current_founded_string
      @current_founded_string = NSMutableString.string
    end
    @current_founded_string.appendString found_chars
  end

  def parser parser,foundCDATA:cdata_block
    @currentCDATAString ||= NSMutableString.alloc.init
    someString = NSMutableString.alloc.initWithData cdata_block,encoding:NSUTF8StringEncoding
    @currentCDATAString.appendString someString
  end

  def parser(parser,didEndElement:el,namespaceURI:namespaceURI,qualifiedName:qName)
    if el == 'title' && @need_create_feed && @feed[:title].nil?
      @feed[:title] = formated_title || '' 
      @feed[:url] = @feed_url
    end

    if @post
      if el == 'title'
        @post[:title] = formated_title 
      end
      if el == 'link' && !@post[:link]
        @post[:link] = @current_founded_string 
      end

      if BodyMark.include?(el)
        @post[:body] = @currentCDATAString ? @currentCDATAString : @current_founded_string
      end
      @post[:created_at] = DateTime.parse(@current_founded_string).to_time if PubDateMark.include? el
      @posts << @post if EntryMark.include? el
    end

    @current_founded_string = nil
    @currentCDATAString = nil
  end

  def formated_title
    if @currentCDATAString.nil? 
       @current_founded_string.strip
    else
      @currentCDATAString
    end
  end

end