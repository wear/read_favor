#
#  Helper.rb
#  ReadFavor
#
#  Created by konglingliang on 13-2-14.
#  Copyright 2013年 konglingliang. All rights reserved.
#

# NSLocalizedString is a macro
module Kernel
  private
  
  def NSLocalizedString(key, value)
    NSBundle.mainBundle.localizedStringForKey(key, value:value, table:nil)
  end
end

module Helper
  # def included(base)
  #   base.extend self  
  # end
  class << self
    def alert_if_offline_at(modWin)
      if !self.internet_connection_active
        alert = NSAlert.alloc.init
        alert.setMessageText NSLocalizedString("error_alert",nil)
        alert.setInformativeText NSLocalizedString("offline",nil)
        alert.addButtonWithTitle NSLocalizedString("ok",nil)
        alert.beginSheetModalForWindow modWin,modalDelegate:nil,didEndSelector:nil,contextInfo:nil
        return
      end
    end

    def internet_connection_active
      flags = Pointer.new(:uint)
      flags[0] = 0
      connected = false
      target = SCNetworkReachabilityCreateWithName(nil,'sohu.com'.UTF8String);
      if SCNetworkReachabilityGetFlags(target, flags)
        connected = true if flags.value == KSCNetworkFlagsReachable
      end
      return connected
    end
  end

end


