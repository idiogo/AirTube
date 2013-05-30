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
    _netServiceBrowser= [[NSNetServiceBrowser alloc] init];
	deviceMenuItems = [[NSMutableArray alloc] init];
    _netServiceBrowser.delegate= self;
    [_netServiceBrowser searchForServicesOfType:@"_airplay._tcp" inDomain:@""];
	currentDeviceHostname = @"";
    [self.deviceListTitle setSubmenu:self.deviceListMenu];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing{
    //Find a service, remember that after that you have to resolve the service to know the address
    [_devices addObject:aNetService];
	NSString *deviceName = aNetService.name;
	NSString *deviceUrl = [[[@"http://" stringByAppendingString:[[deviceName stringByReplacingOccurrencesOfString:@" " withString:@"-"] stringByAppendingFormat:@".local:7000/"]] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
	NSMenuItem *deviceMenuItem = [[NSMenuItem alloc] initWithTitle:deviceName action:@selector(useDevice:) keyEquivalent:deviceUrl];
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
	currentDeviceHostname = [(NSMenuItem *)sender keyEquivalent];
}

-(void)doString:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
    NSString * pboardString = [pboard stringForType:NSStringPboardType];
    NSLog(@">>>>>>>>>>> %@",pboardString);
	
	[self getYoutubeMP4FromURL:pboardString];

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
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		//[self runCommand:@"php -f ~/Development/Youtube-Airplay/fsock.php"];
		
		NSString * stringBody = [NSString stringWithFormat:@"%@%@%@",@"Content-Location: ",mp4URL,@"\nStart-Position: 0\n\n"];
		
		
		NSData* body = [stringBody dataUsingEncoding:NSUTF8StringEncoding];
		
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@play", currentDeviceHostname]];
		
		NSMutableURLRequest *request;
		request = [NSMutableURLRequest requestWithURL:url];
		
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody: body];
		[request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
		
		//		[request setValue:@"ios" forHTTPHeaderField:@"device_os"];
		
		NSError *errorReturned;
		NSURLResponse *theResponse = [[NSURLResponse alloc] init];
		[NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
		//	NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		if (errorReturned) {
			
		} else if ([(NSHTTPURLResponse*) theResponse statusCode] != 200) {
			
		} else {
			//			NSError *jsonParsingError = nil;
			//			NSLog(@"%",data);
			
		}
		
		[NSThread sleepForTimeInterval:30];
		[self scrub];
		
		
	});
}

- (void)scrub {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		//[self runCommand:@"php -f ~/Development/Youtube-Airplay/fsock.php"];
		NSString * duration = @"1";
		NSString * position = @"0";
		while (![duration  isEqualToString:position]) {
			
			NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@scrub", currentDeviceHostname]];
			
			NSMutableURLRequest *request;
			request = [NSMutableURLRequest requestWithURL:url];
			
			[request setHTTPMethod:@"GET"];
			
			//		[request setValue:@"ios" forHTTPHeaderField:@"device_os"];
			
			NSError *errorReturned;
			NSURLResponse *theResponse = [[NSURLResponse alloc] init];
			NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
			//	NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
			if (errorReturned) {
				
			} else if ([(NSHTTPURLResponse*) theResponse statusCode] != 200) {
				
			} else {
				//			NSError *jsonParsingError = nil;
				//			NSLog(@"%",data);
				NSString *scrubString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				NSArray *scrubArray = [scrubString componentsSeparatedByString:@"\n"];
				duration = [[scrubArray objectAtIndex:0] stringByReplacingOccurrencesOfString:@"duration: " withString:@""];
				position = [[scrubArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@"position: " withString:@""];
			}
		
		}
		
		
		
	});
}

- (IBAction)stopRunning:(id)sender{
	NSLog(@"%@",_devices);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@stop", currentDeviceHostname]];
		
		NSMutableURLRequest *request;
		request = [NSMutableURLRequest requestWithURL:url];
		
		[request setHTTPMethod:@"POST"];
		
		//		[request setValue:@"ios" forHTTPHeaderField:@"device_os"];
		
		NSError *errorReturned;
		NSURLResponse *theResponse = [[NSURLResponse alloc] init];
		[NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];
	});
	
	
	//	NSAlert* msgBox = [[NSAlert alloc] init];
	//	[msgBox setMessageText: @"Funcionalidade ainda não implementada :("];
	//	[msgBox addButtonWithTitle: @"OK"];
	//	[msgBox runModal];
}

- (IBAction)useClipboardLink:(id)sender{
	NSPasteboard*  myPasteboard  = [NSPasteboard generalPasteboard];
	NSString* link = [myPasteboard  stringForType:NSPasteboardTypeString];
	NSLog(@"%@", link);
	[self getYoutubeMP4FromURL:link];
}


- (NSString *)runCommand:(NSString *) commandToRun{
	
	stopRunning = NO;
	
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command: %@",commandToRun);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		
		[task launch];
		stopRunning = YES;
		
//		dispatch_async(dispatch_get_main_queue(), ^(void) {
//			
//		});
	});
	
	while (!stopRunning) {
		
	}
	
	[task terminate];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;
}

@end
