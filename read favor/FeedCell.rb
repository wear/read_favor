#
#  FeedCell.rb
#  read favor
#
#  Created by konglingliang on 13-2-4.
#  Copyright 2013年 konglingliang. All rights reserved.
#

class FeedCell < NSTableCellView
  attr_accessor :title,:indicator,:updated_at,:budget

  def observeValueForKeyPath(keyPath,ofObject:object,change:change,context:context)
    if change[NSKeyValueChangeNewKey]
      case keyPath
      when 'unread_count'
        @budget.unread_count.stringValue = change[NSKeyValueChangeNewKey]
      when 'updated_at'
        @updated_at.stringValue = change[NSKeyValueChangeNewKey].strftime('%m-%d %H:%M')
      end
    end
  end

  # def observeValueForKeyPath(keyPath,ofObject:object,change:change,context:context)
  #   @unread_count.stringValue = change[NSKeyValueChangeNewKey] if keyPath == 'unread_count'
  # end

  def setBackgroundStyle(style)
    super(style)
    case style
    when NSBackgroundStyleLight
      @updated_at.setTextColor NSColor.blackColor
      @budget.isSelected = false
    when NSBackgroundStyleDark
      @updated_at.setTextColor NSColor.blackColor
      @budget.isSelected = true
    end
  end

end
