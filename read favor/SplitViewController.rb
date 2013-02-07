#
#  splitViewController.rb
#  read favor
#
#  Created by konglingliang on 13-2-6.
#  Copyright 2013年 konglingliang. All rights reserved.
#


class SplitViewController
  attr_accessor :splitView

  def hideSelect(sender)
    feedSelectCollapsed = @splitView.isSubviewCollapsed feedSelectView
    feedSelectCollapsed ? uncollapseSelectView : collapseSelectView
  end

 # 收缩时记下宽度，展开时使用上次的宽度，不是很完美，需要改进
  def uncollapseSelectView
    feedSelectView.setHidden false
    postSelectView.setHidden false

    feedFrame = feedSelectView.frame
    postFrame = postSelectView.frame

    feedFrame.size.width = @dividerSize.valueForKey("feedSelectWidth").integerValue
    postFrame.size.width = @dividerSize.valueForKey("postSelectWidth").integerValue

    @splitView.setDelegate nil

    NSAnimationContext.beginGrouping
    NSAnimationContext.currentContext.setDuration(0.3)
    NSAnimationContext.currentContext.setCompletionHandler ->{ @splitView.setDelegate self }
    feedSelectView.animator.setFrame feedFrame
    postSelectView.animator.setFrame postFrame
    NSAnimationContext.endGrouping
  end

  def collapseSelectView
    @splitView.adjustSubviews

    feedFrame = feedSelectView.frame
    postFrame = postSelectView.frame

    #记下原始的宽度
    @dividerSize ||= NSMutableDictionary.alloc.initWithCapacity 2

    @dividerSize.setValue feedFrame.size.width,forKey:"feedSelectWidth"
    @dividerSize.setValue postFrame.size.width,forKey:"postSelectWidth"

    feedFrame.size.width = 0.0
    postFrame.size.width = 0.0

    # feedSelectView.setAutoresizesSubviews(false) if feedFrame.size.width <= 0
    @splitView.setDelegate nil

    NSAnimationContext.beginGrouping
    NSAnimationContext.currentContext.setDuration 0.3
    NSAnimationContext.currentContext.setCompletionHandler ->{
      @splitView.setDelegate self
      feedSelectView.setHidden true
      postSelectView.setHidden true
    }
    feedSelectView.animator.setFrame feedFrame
    postSelectView.animator.setFrame postFrame
    NSAnimationContext.endGrouping
  end

  def feedSelectView
    @splitView.subviews.objectAtIndex(0)
  end

  def postSelectView
    @splitView.subviews.objectAtIndex(1)
  end

# splitView delegate method
  def splitView(splitView,canCollapseSubview:subview)
    true
  end

  def splitView(sender,constrainMinCoordinate:proposedMin,ofSubviewAt:dividerIndex)
    return proposedMin + 100.0
  end

  def splitView(sender,constrainMaxCoordinate:proposedMax,ofSubviewAt:dividerIndex)
    return proposedMax - 20.0
  end

  def splitView(sender,constrainSplitPosition:proposedPosition,ofSubviewAt:dividerIndex)
    return proposedPosition
  end
end