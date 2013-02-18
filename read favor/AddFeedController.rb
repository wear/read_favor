#
#  AddFeedPanelController.rb
#  ReadFavor
#
#  Created by konglingliang on 13-2-11.
#  Copyright 2013年 konglingliang. All rights reserved.
#

require 'uri'

class AddFeedController < NSWindowController
  attr_accessor :feedUrl,:spinner,:delegate

  def add_feed(sender)
    Helper.alert_if_offline_at self.window
    if valid_url? @feedUrl.stringValue
      sender.Enabled = false
      @spinner.startAnimation nil
      gcdq = Dispatch::Queue.new('com.konglinglinag.readFaver')
      gcdq.async do
        res = @delegate.add_feed @feedUrl.stringValue
        if res[:errors].nil?
          self.close
          @delegate.fetch_feeds_form_db
        else
          NSOperationQueue.mainQueue.addOperationWithBlock -> do
            alert = NSAlert.alloc.init
            alert.setMessageText NSLocalizedString("error_alert",nil)
            alert.setInformativeText res[:errors]
            alert.addButtonWithTitle NSLocalizedString("ok",nil)
            alert.beginSheetModalForWindow self.window,modalDelegate:self,didEndSelector:nil,contextInfo:nil
            @feedUrl.stringValue = ''
            @spinner.stopAnimation nil
            sender.Enabled = true
          end
        end
      end
    else
      alert = NSAlert.alloc.init
      alert.setMessageText NSLocalizedString("error_alert",nil)
      alert.setInformativeText NSLocalizedString("incorrect_feed_url",nil)
      alert.addButtonWithTitle NSLocalizedString("ok",nil)
      alert.beginSheetModalForWindow self.window,modalDelegate:self,didEndSelector:nil,contextInfo:nil
      @feedUrl.stringValue = ''
    end      
  end

protected

  def valid_url?(value)
    valid = begin
      URI.parse(value).kind_of?(URI::HTTP)
    rescue URI::InvalidURIError
      false
    end
  end

end