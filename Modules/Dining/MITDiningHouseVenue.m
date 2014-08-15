#import "MITDiningHouseVenue.h"
#import "MITDiningHouseDay.h"
#import "MITDiningLocation.h"
#import "MITAdditions.h"

@implementation MITDiningHouseVenue

@dynamic iconURL;
@dynamic identifier;
@dynamic name;
@dynamic payment;
@dynamic shortName;
@dynamic location;
@dynamic mealsByDay;

+ (RKMapping *)objectMapping
{
    RKEntityMapping *mapping = [[RKEntityMapping alloc] initWithEntity:[self entityDescription]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"id" : @"identifier",
                                                  @"short_name" : @"shortName",
                                                  @"icon_url" : @"iconURL"}];
    [mapping addAttributeMappingsFromArray:@[@"name", @"payment"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:[MITDiningLocation objectMapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"meals_by_day" toKeyPath:@"mealsByDay" withMapping:[MITDiningHouseDay objectMapping]]];

    [mapping setIdentificationAttributes:@[@"identifier"]];
    
    return mapping;
}

#pragma mark - Convenience Methods

- (BOOL)isOpenNow
{
    NSDate *date = [NSDate date];
    MITDiningHouseDay *day = [self houseDayForDate:date];
    MITDiningMeal *meal = [day mealForDate:date];
    return (meal != nil);
}

- (MITDiningHouseDay *)houseDayForDate:(NSDate *)date
{
    MITDiningHouseDay *returnDay = nil;
    if (date) {
        NSDate *startOfDate = [date startOfDay];
        for (MITDiningHouseDay *day in self.mealsByDay) {
            if ([day.date isEqualToDate:startOfDate]) {
                returnDay = day;
                break;
            }
        }
    }
    return returnDay;
}

- (NSString *)hoursToday
{
    MITDiningHouseDay *today = [self houseDayForDate:[NSDate date]];
    return [today dayHoursDescription];
}

@end
