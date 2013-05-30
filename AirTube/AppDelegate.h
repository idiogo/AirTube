//
//  AppDelegate.h
//  AirTube
//
//  Created by Diogo Carneiro on 27/05/13.
//  Copyright (c) 2013 Diogo Carneiro. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSString+RegularExpressionSearch.h"
#import "NSString+UrlEncode.h"
#import "LBYouTubeExtractor.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSNetServiceBrowserDelegate>{
	BOOL stopRunning;
    NSNetServiceBrowser *_netServiceBrowser;
    NSNetService *_netService;
    NSMutableArray *_devices;
	NSMutableArray *deviceMenuItems;
	NSString *currentDeviceHostname;
	NSStatusItem * statusItem;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) LBYouTubeExtractor* extractor;

@property (weak) IBOutlet NSMenu *statusMenu;

@property (weak) IBOutlet NSMenu *deviceListMenu;
@property (weak) IBOutlet NSMenuItem *deviceListTitle;

- (IBAction)stopRunning:(id)sender;
- (IBAction)useClipboardLink:(id)sender;

@end
