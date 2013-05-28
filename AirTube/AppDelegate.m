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
}

-(void)doString:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
    NSString * pboardString = [pboard stringForType:NSStringPboardType];
    NSLog(@">>>>>>>>>>> %@",pboardString);
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		[self runCommand:@"php -f ~/Development/Youtube-Airplay/fsock.php"];
	});
}

- (IBAction)stopRunning:(id)sender{
	stopRunning = YES;
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
