//
//  NSString+RegularExpressionSearch.m
//  PicPay
//
//  Created by Diogo Carneiro on 07/03/13.
//
//

#import "NSString+RegularExpressionSearch.h"

@implementation NSString (RegularExpressionSearch)

- (NSArray *)stringRangesWithRegularExpressionPattern:(NSString *)patternString{
	NSString *searchedString = self;
	NSError* error = nil;
	NSMutableArray *ranges = [[NSMutableArray alloc] init];
	
	NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:patternString options:0 error:&error];
	NSArray* matches = [regex matchesInString:searchedString options:0 range:NSMakeRange(0, [searchedString length])];
	for ( NSTextCheckingResult* match in matches )
	{
		NSValue *rangeValue = [NSValue valueWithRange:[match range]];
		[ranges addObject:rangeValue];
	}
	
	return ranges;
}

@end
