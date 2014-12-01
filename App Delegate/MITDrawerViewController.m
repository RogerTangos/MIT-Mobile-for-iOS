#import "MITDrawerViewController.h"
#import "MITSlidingViewController.h"
#import "MITModuleItem.h"

static NSString* const MITDrawerReuseIdentifierItemCell = @"ModuleItemCell";
static NSUInteger const MITModuleSectionIndex = 0;

@interface MITDrawerViewController ()
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;
@end

@implementation MITDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Properties
- (void)setModuleItems:(NSArray *)moduleItems
{
    [self setModuleItems:moduleItems animated:NO];
}

- (void)setModuleItems:(NSArray *)moduleItems animated:(BOOL)animated
{
    if (![_moduleItems isEqualToArray:moduleItems]) {

        [self willSetModuleItems:moduleItems animated:animated];

        _moduleItems = [moduleItems copy];

        [self didSetModuleItems:animated];
    }
}

- (void)willSetModuleItems:(NSArray*)newModuleItems animated:(BOOL)animated
{
    /* Do Nothing */
}

- (void)didSetModuleItems:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)setSelectedModuleItems:(MITModuleItem*)selectedModuleItem
{
    [self setSelectedModuleItem:selectedModuleItem animated:NO];
}

- (void)setSelectedModuleItem:(MITModuleItem*)selectedModuleItem animated:(BOOL)animated
{
    if (![_selectedModuleItem isEqual:selectedModuleItem]) {
        [self willSetSelectedModuleItem:selectedModuleItem animated:animated];

        _selectedModuleItem = selectedModuleItem;

        [self didSetSelectedModuleItem:animated];
    }
}

- (void)willSetSelectedModuleItem:(MITModuleItem*)newSelectedModuleItem animated:(BOOL)animated
{
    NSIndexPath *oldSelectedIndexPath = [self _indexPathForModuleItem:newSelectedModuleItem];

    [self.tableView beginUpdates];

    if (oldSelectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:oldSelectedIndexPath animated:animated];
    }
}

- (void)didSetSelectedModuleItem:(BOOL)animated
{
    NSIndexPath *newSelectedIndexPath = [self _indexPathForModuleItem:self.selectedModuleItem];

    if (newSelectedIndexPath) {
        [self.tableView selectRowAtIndexPath:newSelectedIndexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
    }

    [self.tableView endUpdates];
}

#pragma mark Private
- (NSUInteger)_numberOfModuleItemsWithType:(MITModuleType)type
{
    __block NSUInteger numberOfModuleItems = 0;
    [self.moduleItems enumerateObjectsUsingBlock:^(MITModuleItem *moduleItem, NSUInteger idx, BOOL *stop) {
        if (moduleItem.type == type) {
            ++numberOfModuleItems;
        }
    }];

    return numberOfModuleItems;
}

- (NSArray*)_moduleItemsWithType:(MITModuleType)type
{
    NSMutableArray *moduleItems = [[NSMutableArray alloc] init];
    [self.moduleItems enumerateObjectsUsingBlock:^(MITModuleItem *moduleItem, NSUInteger idx, BOOL *stop) {
        if (moduleItem.type == type) {
            [moduleItems addObject:moduleItem];
        }
    }];

    return moduleItems;
}

- (NSIndexPath*)_indexPathForModuleItem:(MITModuleItem*)moduleItem
{
    if (moduleItem) {
        NSUInteger section = moduleItem.type;
        NSUInteger row = [[self _moduleItemsWithType:moduleItem.type] indexOfObject:moduleItem];

        NSAssert(row != NSNotFound,@"module item with name %@ does not exist",moduleItem.name);
        return [NSIndexPath indexPathForRow:row inSection:section];
    } else {
        return nil;
    }
}

- (MITModuleItem*)_moduleItemForIndexPath:(NSIndexPath*)indexPath
{
    MITModuleType type = (MITModuleType)indexPath.section;
    NSArray *moduleItems = [self _moduleItemsWithType:type];
    return moduleItems[indexPath.row];
}

#pragma mark - Delegation
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MITModuleType type = (MITModuleType)section;
    return [[self _moduleItemsWithType:type] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MITDrawerReuseIdentifierItemCell forIndexPath:indexPath];
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        MITModuleItem *moduleItem = [self _moduleItemForIndexPath:indexPath];

        if (moduleItem.type == MITModuleTypePrimary) {
            cell.imageView.image = moduleItem.image;
        }

        cell.textLabel.text = moduleItem.title;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    return cell;
}

#pragma mark UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];

    MITModuleItem *selectedModuleItem = [self _moduleItemForIndexPath:indexPath];
    self.selectedModuleItem = selectedModuleItem;

    if ([self.delegate respondsToSelector:@selector(drawerViewController:didSelectModuleItem:)]) {
        [self.delegate drawerViewController:self didSelectModuleItem:selectedModuleItem];
    }
}

@end
