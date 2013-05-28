//
//  NSString+RegularExpressionSearch.h
//  PicPay
//
//  Created by Diogo Carneiro on 07/03/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (RegularExpressionSearch)

- (NSArray *)stringRangesWithRegularExpressionPattern:(NSString *)patternString;

@end
