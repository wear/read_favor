#
#  RecommandedFeed.rb
#  ReadFavor
#
#  Created by konglingliang on 13-2-13.
#  Copyright 2013年 konglingliang. All rights reserved.
#

class RecommandedFeed
  attr_accessor :title,:description,:url,:selected

  def self.initWithInfo(title,description,url)
    feed = RecommandedFeed.alloc.init
    feed.title = title
    feed.description = description
		feed.url = url
  	feed.selected = true
    return feed
  end
end
