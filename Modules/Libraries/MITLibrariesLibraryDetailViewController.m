#import "MITLibrariesLibraryDetailViewController.h"
#import "MITLibrariesLibrary.h"
#import "MITLibrariesHoursCell.h"
#import "MITLibrariesTerm.h"
#import "UIKit+MITAdditions.h"
#import "UIKit+MITLibraries.h"
#import "MITTiledMapView.h"
#import "MITCalloutMapView.h"
#import "MITLocationManager.h"
#import "MITMapModelController.h"
#import "MITConstants.h"

static NSString *const kMITDefaultCell = @"kMITDefaultCell";
static NSString *const kMITHoursCell = @"MITLibrariesHoursCell";

typedef NS_ENUM(NSInteger, MITLibraryDetailCell) {
    MITLibraryDetailCellPhone,
    MITLibraryDetailCellLocation,
    MITLibraryDetailCellHoursToday,
    MITLibraryDetailCellOther
};

@interface MITLibrariesLibraryDetailViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) MITTiledMapView *mapView;

@end

@implementation MITLibrariesLibraryDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.library.name;

    [self setupTableView];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self setupTableHeader];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationManagerDidUpdateAuthorizationStatus:) name:kLocationManagerDidUpdateAuthorizationStatusNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView
{
    UINib *cellNib = [UINib nibWithNibName:kMITHoursCell bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kMITHoursCell];
}

// We're not getting a coordinate back for the library, so this function isn't currently called
- (void)setupTableHeader
{
    self.mapView = [[MITTiledMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    self.mapView.mapView.showsUserLocation = [MITLocationManager locationServicesAuthorized];
    self.mapView.userInteractionEnabled = NO;
    self.tableView.tableHeaderView = self.mapView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3 + self.library.terms.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < MITLibraryDetailCellOther) {
        return 54.0;
    }
    return [MITLibrariesHoursCell heightForContent:[self termForIndexPath:indexPath] tableViewWidth:self.tableView.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case MITLibraryDetailCellPhone:
            return [self phoneNumberCell];
            break;
        case MITLibraryDetailCellLocation:
            return [self locationCell];
            break;
        case MITLibraryDetailCellHoursToday:
            return [self hoursTodayCell];
            break;
        case MITLibraryDetailCellOther:
        default:
            return [self termHoursCellForIndexPath:indexPath];
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case MITLibraryDetailCellPhone:
        {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Call %@?", self.library.phoneNumber] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                [alert show];
            }
        }
            break;
        case MITLibraryDetailCellLocation:
        {
            NSString *urlString = [NSString stringWithFormat:@"%@://%@/search/%@",MITInternalURLScheme, MITModuleTagCampusMap, [MITMapModelController sanitizeMapSearchString:self.library.location]];
            NSURL *url = [NSURL URLWithString:urlString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
            break;
        case MITLibraryDetailCellHoursToday:
        case MITLibraryDetailCellOther:
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.library.phoneNumber]];
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
}

- (UITableViewCell *)phoneNumberCell
{
    UITableViewCell *cell = [self defaultCell];
    cell.textLabel.text = @"phone";
    cell.detailTextLabel.text = self.library.phoneNumber;
    cell.accessoryView = [UIImageView accessoryViewWithMITType:MITAccessoryViewPhone];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

- (UITableViewCell *)locationCell
{
    UITableViewCell *cell = [self defaultCell];
    cell.textLabel.text = @"location";
    cell.detailTextLabel.text = self.library.location;
    cell.accessoryView = [UIImageView accessoryViewWithMITType:MITAccessoryViewMap];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

- (UITableViewCell *)hoursTodayCell
{
    UITableViewCell *cell = [self defaultCell];
    cell.textLabel.text = @"today's hours";
    cell.detailTextLabel.text = [self.library hoursStringForDate:[NSDate date]];
    cell.accessoryView = nil;
    return cell;
}

- (UITableViewCell *)termHoursCellForIndexPath:(NSIndexPath *)indexPath
{
    MITLibrariesHoursCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kMITHoursCell forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setContent:[self termForIndexPath:indexPath]];
    
    return cell;
}

- (UITableViewCell *)defaultCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kMITDefaultCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kMITDefaultCell];
        cell.textLabel.textColor = [UIColor mit_tintColor];
        cell.textLabel.font = [UIFont librariesSubtitleStyleFont];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:17.0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (MITLibrariesTerm *)termForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row - 3;
    return self.library.terms[index];
}

- (void)dismiss
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Location Notifications

- (void)locationManagerDidUpdateAuthorizationStatus:(NSNotification *)notification
{
    self.mapView.mapView.showsUserLocation = [MITLocationManager locationServicesAuthorized];
}

@end