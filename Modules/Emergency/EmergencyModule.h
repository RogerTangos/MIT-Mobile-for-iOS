#import "MITNavigationModule.h"
#import "EmergencyViewController.h"

@interface EmergencyModule : MITNavigationModule <EmergencyViewControllerDelegate>
@property(nonatomic,strong) EmergencyViewController *rootViewController;

- (instancetype)init;

- (void)syncUnreadNotifications DEPRECATED_ATTRIBUTE;
@end
