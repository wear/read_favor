#
#  RecommandedFeedController.rb
#  ReadFavor
#
#  Created by konglingliang on 13-2-13.
#  Copyright 2013年 konglingliang. All rights reserved.
#

require 'RecommandedFeed'

class RecommandedFeedController < NSWindowController
  attr_accessor :feeds,:delegate,:array_controller
  
  def add_recommand_feeds(sender)
    Helper.alert_if_offline_at self.window
    selected_feeds = []
    gcdq = Dispatch::Queue.new('com.konglinglinag.readFaver')

    @array_controller.arrangedObjects.each do |feed|
      if feed.selected == true
        gcdq.async do
          @delegate.add_feed feed.url
          @delegate.fetch_feeds_form_db
        end
      end
    end
    self.close 
  end
end