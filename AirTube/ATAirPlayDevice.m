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
	[self setIsPlayng:NO];
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
		
		[self scrub];
	});
}

- (void)airPlayPhotoWithURL: (NSString *)photoUrl{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		
		NSData *body = [NSData dataWithContentsOfURL:[NSURL URLWithString:photoUrl]];
        [self airPlayPhoto:body];
        
	});
}

- (void)airPlayPhotoFromFile: (NSString *)photoFilename{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		
		NSData *body = [NSData dataWithContentsOfFile:photoFilename];
        [self airPlayPhoto:body];
        
	});
}

- (void)airPlayPhoto:(NSData *)photoData{
	[self doRequestWithAction:@"photo" requestMethod:@"PUT" resquestBody:photoData];
}

- (void)scrub {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		float duration = 1;
		float position = 0;
		float rate = 1;
		BOOL readyToPlay = false;
		
		while (!readyToPlay) {
			readyToPlay = [[[self playbackInfo] objectForKey:@"readyToPlay"] boolValue];
		}
		[self setIsPlayng:YES];
		while (duration > position && rate == 1) {
			
			if(!self.isPlayng) {
				break;
			}
			
			NSDictionary *plist = [self playbackInfo];
			
			duration = [[plist objectForKey:@"rate"] floatValue];
			duration = [[plist objectForKey:@"duration"] floatValue];
			position = [[plist objectForKey:@"position"] floatValue];
			
			duration = duration *10;
			position = position *10;
			
			duration = truncf(duration);
			position = truncf(position);					

		}
		
		[self stopAirPlay];
		
		
	});
}

-(NSDictionary *)playbackInfo{
	NSData *data = [self doRequestWithAction:@"playback-info" requestMethod:@"GET"];
	
	NSString *error;
	NSPropertyListFormat format;
	NSDictionary *plist = [NSPropertyListSerialization propertyListFromData:data
														   mutabilityOption:NSPropertyListImmutable
																	 format:&format
														   errorDescription:&error];
	return plist;
}

- (void)stopAirPlay{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
		[self setIsPlayng:NO];
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
