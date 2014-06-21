//
//  PeopleFavoriteData.h
//  MIT Mobile
//
//  Created by Yev Motov on 6/19/14.
//
//

#import <Foundation/Foundation.h>
#import "PersonDetails.h"

@interface PeopleFavoriteData : NSObject

+ (void) setPerson:(PersonDetails *)person asFavorite:(BOOL)isFavorite;
+ (NSArray *) retrieveFavoritePeople;

@end
