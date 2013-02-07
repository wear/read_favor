#
#  Budget.rb
#  read favor
#
#  Created by konglingliang on 13-2-5.
#  Copyright 2013年 konglingliang. All rights reserved.
#

class NSColor
  def self.colorFromRGBValue(red,green,blue,alpha)
    NSColor.colorWithCalibratedRed(red/255.0,green:green/255.0,blue:blue/255.0,alpha:alpha)
  end
end

class Budget < NSView
  attr_accessor :unread_count,:isSelected

  BudgetWidthOffset = 10

  def initWithFrame(frame)
    super(frame)
  end

  def observeValueForKeyPath(keyPath,ofObject:object,change:change,context:context)
    @unread_count.stringValue = change[NSKeyValueChangeNewKey] if keyPath == 'unread_count'
  end

  def drawRect(dirtyRect)
    attr = NSMutableDictionary.dictionary
    attr.setObject NSFont.fontWithName('Arial',size:10),forKey:NSFontAttributeName
    unreadRectSize = @unread_count.stringValue.sizeWithAttributes attr
    textWidth = ((self.bounds.size.width - @unread_count.frame.size.width)/2)+10
    textHeight = ((self.bounds.size.height - @unread_count.frame.size.height)/2)-7
    @unread_count.setFrameOrigin NSMakePoint(textWidth,textHeight)
    #文字颜色
    @unread_count.textColor = @isSelected ? NSColor.colorFromRGBValue(51,92,210,1.0) : NSColor.whiteColor
    #画椭圆
    bounds = NSMakeRect(self.bounds.origin.x, self.bounds.origin.y, unreadRectSize.width+BudgetWidthOffset, unreadRectSize.height)
    (@isSelected ? NSColor.whiteColor : NSColor.colorFromRGBValue(130,138,149,1.0)).setFill
    NSBezierPath.bezierPathWithOvalInRect(bounds).fill
  end
end