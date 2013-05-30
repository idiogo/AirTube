//
//  ATAirPlayDevice.h
//  AirTube
//
//  Created by Joao Victor V lana on 30/05/13.
//  Copyright (c) 2013 Diogo Carneiro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATAirPlayDevice : NSObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *hostName;
@property (strong,nonatomic) NSString *url;

-(void)airPlayVideoWithURL:(NSString *)mp4URL;
-(void)stopAirPlay;
-(id)initWithHostName:(NSString *)hostName;

@end
