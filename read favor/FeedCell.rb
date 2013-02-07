#
#  FeedCell.rb
#  read favor
#
#  Created by konglingliang on 13-2-4.
#  Copyright 2013年 konglingliang. All rights reserved.
#

class FeedCell < NSTableCellView
  attr_accessor :title,:indicator,:updated_at,:budget

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
