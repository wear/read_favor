#
#  PostCell.rb
#  read favor
#
#  Created by konglingliang on 13-2-4.
#  Copyright 2013年 konglingliang. All rights reserved.
#


class PostCell < NSTableCellView
  attr_accessor :title,:unread

  def observeValueForKeyPath(keyPath,ofObject:object,change:change,context:context)
    if object.class.to_s.match('Post')
      # p change[NSKeyValueObservingOptionNew]
      # if change[NSKeyValueObservingOptionNew].feed == change[NSKeyValueObservingOptionOld].feed
        @unread.setHidden(true) if keyPath == 'unread'
      # end
    end
  end
end