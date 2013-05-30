//
//  ATAirPlayDevice.m
//  AirTube
//
//  Created by Joao Victor V lana on 30/05/13.
//  Copyright (c) 2013 Diogo Carneiro. All rights reserved.
//

#import "ATAirPlayDevice.h"

@implementation ATAirPlayDevice

-(id)initWithName:(NSString *)name{
    self = [super init];
    if(self) {
        self.name = name;
		self.hostName = [[[@"http://" stringByAppendingString:[[name stringByReplacingOccurrencesOfString:@" " withString:@"-"] stringByAppendingFormat:@".local:7000/"]] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""];
    }
    return self;
}

- (void)airPlayVideoWithURL: (NSString *)mp4URL{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		//[self runCommand:@"php -f ~/Development/Youtube-Airplay/fsock.php"];
		
		NSString * stringBody = [NSString stringWithFormat:@"%@%@%@",@"Content-Location: ",mp4URL,@"\nStart-Position: 0\n\n"];
		NSData* body = [stringBody dataUsingEncoding:NSUTF8StringEncoding];
        
        [self doRequestWithAction:@"play" requestMethod:@"POST" resquestBody:body];
		
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
			NSData *data = [self doRequestWithAction:@"scrub" requestMethod:@"GET"];
			
            NSString *scrubString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSArray *scrubArray = [scrubString componentsSeparatedByString:@"\n"];
            duration = [[scrubArray objectAtIndex:0] stringByReplacingOccurrencesOfString:@"duration: " withString:@""];
            position = [[scrubArray objectAtIndex:1] stringByReplacingOccurrencesOfString:@"position: " withString:@""];
            
		}
		
		
		
	});
}

-(NSData *)doRequestWithAction:(NSString *)action requestMethod:(NSString *)requestMethod{
    return [self doRequestWithAction:action requestMethod:requestMethod resquestBody:nil];
}

-(NSData *)doRequestWithAction:(NSString *)action requestMethod:(NSString *)requestMethod resquestBody:(NSData *)requestBody{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.hostName, action]];
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:requestMethod];

    NSError *errorReturned;
    NSURLResponse *theResponse = [[NSURLResponse alloc] init];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&errorReturned];

    if (errorReturned) {
        return nil;
    } else if ([(NSHTTPURLResponse*) theResponse statusCode] != 200) {
        return nil;
    } else {
        return data;
    }
}



@end
