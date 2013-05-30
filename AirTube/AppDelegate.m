//
//  AppDelegate.m
//  AirTube
//
//  Created by Diogo Carneiro on 27/05/13.
//  Copyright (c) 2013 Diogo Carneiro. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [NSApp setServicesProvider:self];
    _devices = [[NSMutableArray alloc] init];
	_netServices = [[NSMutableArray alloc] init];
    _netServiceBrowser= [[NSNetServiceBrowser alloc] init];
	deviceMenuItems = [[NSMutableArray alloc] init];
    _netServiceBrowser.delegate= self;
    [_netServiceBrowser searchForServicesOfType:@"_airplay._tcp" inDomain:@""];
    [self.deviceListTitle setSubmenu:self.deviceListMenu];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
    [_netServices addObject:aNetService];
	aNetService.delegate = self;
	[aNetService resolveWithTimeout:5];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender{
	NSLog(@"%@ <<<", sender.hostName);
	
	NSNetService *aNetService = (NSNetService *)sender;
	NSString *deviceName = aNetService.name;
	
//	NSString *deviceUrl = [[[@"http://" stringByAppendingString:[[deviceName stringByReplacingOccurrencesOfString:@" " withString:@"-"] stringByAppendingFormat:@".local:7000/"]] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
//	NSString *deviceUrl = @"http://local._airplay._tcp.Sales-TV:7000/";
//	NSString *deviceUrl = [NSString stringWithFormat:@"http://%@:7000/", aNetService.hostName];
	
	NSMenuItem *deviceMenuItem = [[NSMenuItem alloc] initWithTitle:deviceName action:@selector(useDevice:) keyEquivalent:aNetService.hostName];
	[self.deviceListMenu addItem:deviceMenuItem];
	[deviceMenuItems addObject:deviceMenuItem];
	[deviceMenuItem setState:0];
	[self useDevice:deviceMenuItem];
}

-(void)awakeFromNib{
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:17.0f];
	[statusItem setMenu:self.statusMenu];
	[statusItem setImage:[NSImage imageNamed:@"airtube_statusbar"]];
	[statusItem setHighlightMode:YES];
}

- (void)useDevice:(id)sender{
	NSLog(@"%@", [(NSMenuItem *)sender keyEquivalent]);
	for (NSMenuItem *item in deviceMenuItems) {
		[item setState:0];
	}
	[(NSMenuItem *)sender setState:1];
	currentDevice = [[ATAirPlayDevice alloc] initWithHostName:[sender keyEquivalent]];
}

-(void)doString:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
    NSString * pboardString = [pboard stringForType:NSStringPboardType];
    [self airPlayMedia:pboardString];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{
	NSLog(@"%@", filename);
	[self airPlayMedia:filename];
	return true;
}

- (BOOL)isVideo:(NSString *)mediaUrl{
	return [mediaUrl rangeOfString:@"youtube.com/watch"].location != NSNotFound;
}

- (BOOL)isRemoteUrl:(NSString *)mediaUrl{
	return [mediaUrl rangeOfString:@"http"].location != NSNotFound;
}

- (void) getYoutubeMP4FromURL:(NSString *)urlString {
	NSURL *youTubeURL = [NSURL URLWithString:urlString];
	self.extractor = [[LBYouTubeExtractor alloc] initWithURL:youTubeURL quality:2];
	AppDelegate *selfAux = self;
	self.extractor.completionBlock = ^(NSURL *url,NSError *error){
		[selfAux airPlayVideoWithURL:[url absoluteString]];
	};
	[self.extractor startExtracting];
}

- (void)airPlayVideoWithURL: (NSString *)mp4URL{
	[currentDevice airPlayVideoWithURL:mp4URL];
}


- (IBAction)stopRunning:(id)sender{
	[currentDevice stopAirPlay];
}

- (void)airPlayMedia:(NSString *)mediaUrl{
	NSLog(@">>>>>>>>>>> %@",mediaUrl);
	if ([self isVideo:mediaUrl]) {
		[self getYoutubeMP4FromURL:mediaUrl];
	}else{
		if ([self isRemoteUrl:mediaUrl]) {
			[currentDevice airPlayPhotoWithURL:mediaUrl];
		}else{
			[currentDevice airPlayPhotoFromFile:mediaUrl];
		}
	}
}

- (IBAction)useClipboardLink:(id)sender{
	NSPasteboard*  myPasteboard  = [NSPasteboard generalPasteboard];
	NSString* link = [myPasteboard  stringForType:NSPasteboardTypeString];
	[self airPlayMedia:link];
}


@end
