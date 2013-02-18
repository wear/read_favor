#
#  File.rb
#  read favor
#
#  Created by konglingliang on 13-2-4.
#  Copyright 2013年 konglingliang. All rights reserved.
#
# require 'parser'
# require 'PostController'
# require 'AddFeedController'
# require 'RecommandedFeed'
# require 'Helper'

class FeedController
  attr_accessor :feeds_tableview,:addFeedPanel,:post_controller

  def awakeFromNib
    @context = NSApp.delegate.managedObjectContext
    fetch_feeds_form_db
    show_recommanded_fees(nil) if @feeds.size == 0
    # NSTimer.scheduledTimerWithTimeInterval 30,target:self, selector: :'inteval_update_all', userInfo:nil, repeats:true
  end

  def fetch_feeds_form_db
    @feeds = []
    request = NSFetchRequest.alloc.init
    request.setFetchLimit 30
    request.entity = NSEntityDescription.entityForName("Feed",
                                                       inManagedObjectContext:@context)
    sort_desc = NSSortDescriptor.alloc.initWithKey("updated_at",
                                                   ascending:false)
    request.sortDescriptors = [sort_desc]
    error = Pointer.new_with_type("@")
    @feeds = @context.executeFetchRequest(request, error:error)
    # 显示推荐
    if @feeds.size == 0
    end
    NSOperationQueue.mainQueue.addOperationWithBlock ->{ 
      indexes = @feeds_tableview.selectedRowIndexes
      @feeds_tableview.reloadData 
      @feeds_tableview.selectRowIndexes(indexes,byExtendingSelection:false) if indexes.firstIndex != NSNotFound
    }
  end

  def show_recommanded_fees(sender)
    if !@recommadedFeedController
      @recommadedFeedController = RecommandedFeedController.alloc.initWithWindowNibName('Recommanded')
      @recommadedFeedController.delegate = self
      history = RecommandedFeed.initWithInfo '国家人文历史','真相·趣味·良知','http://wenshicankao001.blog.163.com/rss/'
      dapengti = RecommandedFeed.initWithInfo '喷嚏网','阅读、发现和分享：8小时外的健康生活！','http://dapenti.org/blog/rss2.asp'
      ruan = RecommandedFeed.initWithInfo '阮一峰的网络日志','阮一峰的网络日志','http://www.ruanyifeng.com/blog/atom.xml'
      ftime = RecommandedFeed.initWithInfo 'FT中文网_英国《金融时报》(Financial Times)','FT中文网每日新闻','http://www.ftchinese.com/rss/feed'
      @recommadedFeedController.feeds = [history,dapengti,ruan,ftime]
    end
    @recommadedFeedController.showWindow self
  end

  def show_addfeed_view(sender)
    if !@addFeedController
      @addFeedController = AddFeedController.alloc.initWithWindowNibName('AddFeed')
      @addFeedController.delegate = self
    end
    @addFeedController.showWindow self
  end

  def add_feed(feed_url)
    request = NSFetchRequest.fetchRequestWithEntityName 'Feed'
    request.predicate = NSPredicate.predicateWithFormat("url = %@",feed_url)
    error = Pointer.new_with_type("@")
    feed = @context.executeFetchRequest(request, error:error).first
    if feed
      {:errors => NSLocalizedString("exsit_feed",nil)}
      # update_feed(feed)
      # fetch_feeds_form_db
    else
      parser = Parser.new 
      if parser.fetch_feed_data(feed_url:feed_url) && parser.posts.size > 0 
        feed = create_feed({url:feed_url,title:parser.feed[:title]})
        parser.posts.each do |post|
          add_post_to_feed(feed,post)
        end
        NSApp.delegate.saveAction(self)
        {:errors => nil}
      else
        {:errors => NSLocalizedString('cant_find_feed',nil) }
      end
    end
  end

  def add_recommanded_feeds(feeds)
    gcdq = Dispatch::Queue.new('com.konglinglinag.readFaver')
    feeds.each do |recommend_feed|
      gcdq.async do
        add_feed recommend_feed[:url]
      end
    end
  end

  def remove_feed(sender)
    indexes = @feeds_tableview.selectedRowIndexes
    if(indexes.firstIndex != NSNotFound)
      modWin = NSApp.mainWindow
      alert = NSAlert.alloc.init
      alert.setMessageText NSLocalizedString("alert",nil)
      alert.setInformativeText NSLocalizedString("delete_feed_alert",nil)
      alert.addButtonWithTitle NSLocalizedString("cancel",nil)
      alert.addButtonWithTitle NSLocalizedString('remove',nil)
      alert.beginSheetModalForWindow modWin,modalDelegate:self,didEndSelector: :'deleteAlertDidEnd:returnCode:contextInfo:',contextInfo:nil
    else
      showAlterWithMessage NSLocalizedString("must_select_feed",nil)
    end
  end

  def deleteAlertDidEnd(alert,returnCode:returnCode,contextInfo:info)
    if (returnCode == NSAlertSecondButtonReturn) 
      indexes = @feeds_tableview.selectedRowIndexes
      @context.deleteObject @feeds[indexes.firstIndex]
      NSApp.delegate.saveAction(self)
      fetch_feeds_form_db
    end
  end

  def update_selected_feed(sender)
    Helper.alert_if_offline_at NSApp.mainWindow

    indexes = @feeds_tableview.selectedRowIndexes
    if (indexes.firstIndex != NSNotFound)
      row_index = indexes.firstIndex
      feed = @feeds[row_index]
      gcdq = Dispatch::Queue.new('com.konglinglinag.readFaver')
      gcdq.async do
        update_feed row_index
        @post_controller.display_posts_from_feed(feed)
      end
    else 
      showAlterWithMessage NSLocalizedString("must_select_feed",nil)
    end
  end

  def update_feed(row_index)
    feed = @feeds[row_index]
    feedCell = @feeds_tableview.viewAtColumn(0,row:row_index,makeIfNecessary:false)
    feedCell.indicator.startAnimation nil
    feedCell.budget.setHidden(true)
    parser = Parser.new
    parser.update_feed_data(feed:feed)
    parser.posts.each do |post|
      # 检查是否存在  
      request = NSFetchRequest.fetchRequestWithEntityName 'Post'
      request.predicate = NSPredicate.predicateWithFormat("title = %@",post[:title])
      error = Pointer.new_with_type("@")
      founded_post = @context.executeFetchRequest(request, error:error).first
      add_post_to_feed(feed,post) unless founded_post
    end
    feed.updated_at = Time.now
    NSApp.delegate.saveAction(nil)
    # 加到主线程去跑
    feedCell.budget.setHidden(false)
    feedCell.indicator.stopAnimation nil          
  end

  def update_all(sender)
    Helper.alert_if_offline_at NSApp.mainWindow
    gcdq = Dispatch::Queue.new('com.konglinglinag.readFaver')
    @feeds_tableview.enumerateAvailableRowViewsUsingBlock ->(rowView,row){
      gcdq.async { update_feed(row)  }
    }
  end

  def inteval_update_all
    gcdq = Dispatch::Queue.new('com.konglinglinag.readFaver')
    @feeds_tableview.enumerateAvailableRowViewsUsingBlock ->(rowView,row){
      gcdq.async do
        update_feed(row) 
      end
    }
    gcdq.async{ NSOperationQueue.mainQueue.addOperationWithBlock ->{ fetch_feeds_form_db } }
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
    feed.addObserver(feed_cell,forKeyPath:"unread_count",options:NSKeyValueObservingOptionNew,context:nil)  
    feed.addObserver(feed_cell,forKeyPath:"updated_at",options:NSKeyValueObservingOptionNew,context:nil)
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
    alert.setMessageText NSLocalizedString("error_alert",nil)
    alert.setInformativeText msg
    alert.addButtonWithTitle  NSLocalizedString("ok",nil)
    alert.beginSheetModalForWindow modWin,modalDelegate:self,didEndSelector:nil,contextInfo:nil
  end

  protected

  def create_feed(feed_info)
    feed = NSEntityDescription.insertNewObjectForEntityForName("Feed",inManagedObjectContext:@context)
    feed.title = feed_info[:title] #parser.feed[:title]
    feed.url = feed_info[:url] #feed_url
    feed.updated_at = Time.now
    feed    
  end

  def add_post_to_feed(feed,post_hash)
    post = NSEntityDescription.insertNewObjectForEntityForName("Post",inManagedObjectContext:@context)
    post.title = post_hash[:title]
    post.body = post_hash[:body]
    post.created_at = post_hash[:created_at]
    post.feed = feed
    feed.unread_count += 1
  end

end
