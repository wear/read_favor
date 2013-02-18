#
#  PostViewController.rb
#  read favor
#
#  Created by konglingliang on 13-2-8.
#  Copyright 2013年 konglingliang. All rights reserved.
#

class PostView < WebView
  attr_accessor :navigate_delegate

  def swipeWithEvent(event)
    x = event.deltaX
    y = event.deltaY
    
    if x != 0
      if (x > 0) 
        @navigate_delegate.pre_post
      else 
        @navigate_delegate.next_post
      end
    end
  end

  def recognizeTwoFingerGestures
    defaults = NSUserDefaults.standardUserDefaults
    return defaults.boolForKey 'AppleEnableSwipeNavigateWithScrolls'
  end

end

