//
//  main.m
//  staging
//
//  Created by konglingliang on 13-2-7.
//  Copyright (c) 2013年 konglingliang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
  return macruby_main("rb_main.rb", argc, argv);
}
