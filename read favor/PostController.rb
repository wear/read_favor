#
#  PostController.rb
#  read favor
#
#  Created by konglingliang on 13-2-4.
#  Copyright 2013年 konglingliang. All rights reserved.
#
require 'PostCell'

class PostController
  attr_accessor :webview,:posts_tableview

  def awakeFromNib
    @context = NSApp.delegate.managedObjectContext
  end
  
  def display_posts_from_feed(feed)
    last_selected_index = if @feed != feed
      nil
    else
      @posts_tableview.selectedRowIndexes
    end

    @feed = feed
    @posts = []
    request = NSFetchRequest.alloc.init
    # request.setFetchLimit 45
    request.entity = NSEntityDescription.entityForName("Post",
                                                       inManagedObjectContext:@context)
    request.predicate = NSPredicate.predicateWithFormat("feed = %@",feed)
    sort_desc = NSSortDescriptor.alloc.initWithKey("created_at",ascending:false)
    request.sortDescriptors = [sort_desc]

    error = Pointer.new_with_type("@")
    @posts = @context.executeFetchRequest(request, error:error)
    NSOperationQueue.mainQueue.addOperationWithBlock(lambda{ 
      @posts_tableview.reloadData 
      @posts_tableview.selectRowIndexes(last_selected_index,byExtendingSelection:false) if last_selected_index && last_selected_index.firstIndex != NSNotFound
    })
  end

  #　datasource协议实现
  def numberOfRowsInTableView(view)
    @posts ? @posts.size : 0
  end

  def tableView(tableView,viewForTableColumn:col,row:index)
    post = @posts[index]
    post_cell = tableView.makeViewWithIdentifier('post',owner:self)
    post_cell.title.stringValue = post.title
    post_cell.unread.setHidden post.unread == 0

    post.addObserver(post_cell,forKeyPath:"unread",options:NSKeyValueObservingOptionNew,context:nil)    
    return post_cell
  end

  def tableViewSelectionDidChange(aNotification)
    indexes = aNotification.object.selectedRowIndexes

    if (indexes.firstIndex != NSNotFound) 
      post = @posts[indexes.firstIndex]
      # 最后选择的内容
      if post.unread == 1
        post.unread = false
        @feed.unread_count -= 1
        NSApp.delegate.saveAction(self)
        # post_cell = @posts_tableview.viewAtColumn(0,row:indexes.firstIndex,makeIfNecessary:false)
        # post_cell.unread.setHidden(true) if post_cell
      end
      css_url = NSBundle.mainBundle.URLForResource('main.css',withExtension:nil)
      htmlBody = ""
      htmlBody += "<html><head> <link rel='stylesheet' type='text/css' href='#{css_url.absoluteString}'></head><body>"
      htmlBody += "<h1>#{post.title}</h1>"
      htmlBody += "#{post.body}"
      htmlBody += "</body></html>"

      self.webview.mainFrame.loadHTMLString(htmlBody,baseURL:nil)  
    end
  end

  def pre_post
    indexes = @posts_tableview.selectedRowIndexes
    if(indexes.firstIndex != NSNotFound && indexes.firstIndex > 0)
      new_indexes = NSIndexSet.indexSetWithIndex indexes.firstIndex - 1
      @posts_tableview.selectRowIndexes new_indexes,byExtendingSelection:false
    end
  end

  def next_post
    indexes = @posts_tableview.selectedRowIndexes
    if(indexes.firstIndex != NSNotFound && indexes.firstIndex < @posts.size )
      new_indexes = NSIndexSet.indexSetWithIndex indexes.firstIndex + 1
      @posts_tableview.selectRowIndexes new_indexes,byExtendingSelection:false
    end
  end

end