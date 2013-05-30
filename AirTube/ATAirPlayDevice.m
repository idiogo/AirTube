//
//  ATAirPlayDevice.m
//  AirTube
//
//  Created by Joao Victor V lana on 30/05/13.
//  Copyright (c) 2013 Diogo Carneiro. All rights reserved.
//

#import "ATAirPlayDevice.h"

@implementation ATAirPlayDevice

-(id)initWithHostName:(NSString *)hostName{
    self = [super init];
    if(self) {
        self.hostName = hostName;
		self.url = [NSString stringWithFormat:@"http://%@:7000/", hostName];
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

- (void)airPlayPhotoWithURL: (NSString *)photoUrl{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		//[self runCommand:@"php -f ~/Development/Youtube-Airplay/fsock.php"];
		
		NSData *body = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
        
        [self doRequestWithAction:@"photo" requestMethod:@"PUT" resquestBody:body];
	});
}

- (void)scrub {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
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

- (void)stopAirPlay{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        [self doRequestWithAction:@"stop" requestMethod:@"POST"];
	});
}

-(NSData *)doRequestWithAction:(NSString *)action requestMethod:(NSString *)requestMethod{
    return [self doRequestWithAction:action requestMethod:requestMethod resquestBody:nil];
}

-(NSData *)doRequestWithAction:(NSString *)action requestMethod:(NSString *)requestMethod resquestBody:(NSData *)requestBody{	
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.url, action]];
    NSLog(@"%@",[NSString stringWithFormat:@"%@%@", self.url, action]);
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:requestMethod];
	if(requestBody != nil) {
			[request setHTTPBody: requestBody];
	}
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
