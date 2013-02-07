#
#  File.rb
#  read favor
#
#  Created by konglingliang on 13-2-4.
#  Copyright 2013年 konglingliang. All rights reserved.
#
require 'parser'
require 'PostController'

class FeedController
  attr_accessor :feeds_tableview,:addFeedPanelController,:addFeedPanel,:feedUrl,:parser,:post_controller

  def awakeFromNib
    @context = NSApp.delegate.managedObjectContext
    @parser ||= Parser.new 
    fetch_feeds_form_db
  end

  def fetch_feeds_form_db
    @feeds = []
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName("Feed",
                                                       inManagedObjectContext:@context)
    sort_desc = NSSortDescriptor.alloc.initWithKey("updated_at",
                                                   ascending:false)
    request.sortDescriptors = [sort_desc]
    error = Pointer.new_with_type("@")
    @feeds = @context.executeFetchRequest(request, error:error)
    NSOperationQueue.mainQueue.addOperationWithBlock ->{ @feeds_tableview.reloadData }
  end

  def show_addfeed_view(sender)
    if (!@addFeedPanelController)
      NSBundle.loadNibNamed "AddFeedView",owner:self
      @addFeedPanelController = NSWindowController.alloc.initWithWindow(@addFeedPanel)
    end
    @addFeedPanelController.showWindow nil
  end

  def add_feed(sender)
    # need verify url
    request = NSFetchRequest.fetchRequestWithEntityName 'Feed'
    request.predicate = NSPredicate.predicateWithFormat("url = %@",@feedUrl.stringValue)
    error = Pointer.new_with_type("@")
    feed = @context.executeFetchRequest(request, error:error).first
    #如果已存在订阅就直接改为更新操作
    if feed
      showAlterWithMessage "订阅已存在！"
      # update_feed(feed)
      # fetch_feeds_form_db
    else
      gcdq = Dispatch::Queue.new('com.konglinglinag.readFaver')
      gcdq.async do
        if @parser.fetch_feed_data(feed_url:@feedUrl.stringValue)
          feed = NSEntityDescription.insertNewObjectForEntityForName("Feed",inManagedObjectContext:@context)
          feed.title = @parser.feed[:title]
          feed.url = @feedUrl.stringValue
          feed.updated_at = Time.now
          @parser.posts.each do |post|
            add_post_to_feed(feed,post)
          end
          NSApp.delegate.saveAction(self)
        end
        fetch_feeds_form_db
      end
    end
    @addFeedPanelController.close
  end

  def remove_feed(sender)
    indexes = @feeds_tableview.selectedRowIndexes
    if(indexes.firstIndex != NSNotFound)
      modWin = NSApp.mainWindow
      alert = NSAlert.alloc.init
      alert.setMessageText "删除警告"
      alert.setInformativeText "删除Fedd将同时删除所有此Feed下的条目，你确定删除吗？"
      alert.addButtonWithTitle "取消"
      alert.addButtonWithTitle '删除'
      alert.beginSheetModalForWindow modWin,modalDelegate:self,didEndSelector: :'deleteAlertDidEnd:returnCode:contextInfo:',contextInfo:nil
    else
      showAlterWithMessage "必须选择一个Feed"
    end
  end

  def deleteAlertDidEnd(alert,returnCode:returnCode,contextInfo:info)
    if (returnCode == NSAlertSecondButtonReturn) 
      indexes = @feeds_tableview.selectedRowIndexes
      @context.deleteObject @feeds[indexes.firstIndex]
      NSApp.delegate.saveAction(self)
      NSOperationQueue.mainQueue.addOperationWithBlock ->{ @feeds_tableview.reloadData }
    end
  end

  def update_selected_feed(sender)
    indexes = @feeds_tableview.selectedRowIndexes
    if (indexes.firstIndex != NSNotFound)
      feed = @feeds[indexes.firstIndex]

      feedCell = @feeds_tableview.viewAtColumn(0,row:indexes.firstIndex,makeIfNecessary:false)
      feedCell.indicator.startAnimation nil
      feedCell.budget.setHidden(true)

      gcdq = Dispatch::Queue.new('com.konglinglinag.readFaver')
      gcdq.async do
        if @parser.update_feed_data(feed:feed)
          @parser.posts.each do |post|
            add_post_to_feed(feed,post) if post[:created_at] > feed.updated_at
          end
          feed.updated_at = Time.now
          NSApp.delegate.saveAction(self)
          @post_controller.display_posts_from_feed(feed)
          feedCell.budget.setHidden(false)
          feedCell.indicator.stopAnimation nil 
        else
          showAlterWithMessage "获取订阅内容出错了！"
        end
      end
    else 
      showAlterWithMessage "必须选择一个Feed"
    end
  end

  #　datasource协议实现
  def numberOfRowsInTableView(view)
    @feeds ? @feeds.size : 0
  end

  def tableView(tableView,viewForTableColumn:col,row:index)
    feed = @feeds[index]
    feed_cell = tableView.makeViewWithIdentifier('feed',owner:self)
    feed_cell.title.stringValue = feed.title
    feed_cell.updated_at.stringValue = feed.updated_at.strftime('%m-%d %H:%M')
    feed_cell.budget.unread_count.stringValue = feed.unread_count
    # feed.addObserver(feed_cell.budget,forKeyPath:"unread_count",options:NSKeyValueObservingOptionNew,context:nil)  
    return feed_cell
  end

  def tableViewSelectionDidChange(aNotification)
    indexes = aNotification.object.selectedRowIndexes
    if (indexes.firstIndex != NSNotFound) 
      feed = @feeds[indexes.firstIndex]
      if @post_controller && @post_controller.respond_to?(:display_posts_from_feed)
        @post_controller.display_posts_from_feed(feed)
      end
    end
  end

  # alert method
  def showAlterWithMessage(msg)
    modWin = NSApp.mainWindow
    alert = NSAlert.alloc.init
    alert.setMessageText "Parsing Error!"
    alert.setInformativeText msg
    alert.addButtonWithTitle 'ok'
    alert.beginSheetModalForWindow modWin,modalDelegate:self,didEndSelector:nil,contextInfo:nil
  end

  protected

  def add_post_to_feed(feed,post_hash)
    post = NSEntityDescription.insertNewObjectForEntityForName("Post",inManagedObjectContext:@context)
    post.title = post_hash[:title]
    post.body = post_hash[:body]
    post.created_at = post_hash[:created_at]
    post.feed = feed
    feed.unread_count += 1
  end

end
