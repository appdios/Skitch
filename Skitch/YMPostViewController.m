//
//  YMPostViewController.m
//  Skitch
//
//  Created by Aditi Kamal on 7/6/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMPostViewController.h"
#import "YMGroupViewController.h"
#import "SVProgressHUD.h"
#import "YMImageAttachmentView.h"

@interface YMPostViewController ()

@property (nonatomic, strong) id groups;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *keyboardDismissButton;
@property (nonatomic, strong) YMImageAttachmentView *attachmentView;
@property (nonatomic) NSInteger selectedGroupIndex;
@end

@implementation YMPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Post to Yammer";
    self.tableView.scrollEnabled = NO;
    [self getGroups];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PostCell"];
    
    self.keyboardDismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    [self.keyboardDismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    self.keyboardDismissButton.backgroundColor = [UIColor grayColor];
    [self.keyboardDismissButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    self.textView = [[UITextView alloc] init];
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    [self.textView setInputAccessoryView:self.keyboardDismissButton];
    
    self.attachmentView = [[YMImageAttachmentView alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width - 40, 80)];
    [self.attachmentView insertThumbnails];
}


- (void)dismissKeyboard{
    [self.textView resignFirstResponder];
//    [UIView animateWithDuration:0.2 animations:^{
//        self.tableView.transform = CGAffineTransformIdentity;
//    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
//    [UIView animateWithDuration:0.2 animations:^{
//        self.tableView.transform = CGAffineTransformMakeTranslation(0, -50);
//    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.textView.frame = CGRectMake(0, 0, self.view.bounds.size.width - 10, 150);
}


- (void)getGroups{
    [SVProgressHUD show];
    [YMNetwork getGroupsForDelegate:self];
}

- (void)groupChangedToIndex:(NSInteger)index{
    self.selectedGroupIndex = index;
    [self.tableView reloadData];
}

- (IBAction)selectGroup{
    [self.textView resignFirstResponder];
    YMGroupViewController *groupController = [[YMGroupViewController alloc] initWithStyle:UITableViewStylePlain andGroups:self.groups];
    groupController.delegate = self;
    groupController.selectedGroupIndex = self.selectedGroupIndex;
    [self.navigationController pushViewController:groupController animated:YES];
}

- (void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"Message";
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44;
    }
    else if(indexPath.section == 1){
        return indexPath.row == 0 ? 160 : 80;
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return section == 1 ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PostCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.attributedText = [self attributedStringForCurrentGroup];
    }
    else if(indexPath.section==1){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row==0) {
            self.textView.frame = CGRectMake(10, 5, cell.bounds.size.width - 10, cell.bounds.size.height - 20);
            [cell addSubview:self.textView];
        }
        else if(indexPath.row==1){
            [cell addSubview:self.attachmentView];
        }
    }
    else if(indexPath.section==2){
        cell.textLabel.text = @"Post";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [self selectGroup];
    }
    else if(indexPath.section == 2){
        [self postMessage];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSAttributedString*)attributedStringForCurrentGroup{
    NSString *groupName = @"All Company";
    if (self.selectedGroupIndex > 0) {
        id group = [self.groups objectAtIndex:self.selectedGroupIndex - 1];
        groupName = [group objectForKey:@"full_name"];
    }
    NSMutableAttributedString *groupString = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *toString = [[NSAttributedString alloc] initWithString:@"To: " attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:18],NSFontAttributeName,[UIColor grayColor], NSForegroundColorAttributeName, nil]];
    [groupString appendAttributedString:toString];
    
    NSAttributedString *nameString = [[NSAttributedString alloc] initWithString:groupName attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName,[UIColor blackColor], NSForegroundColorAttributeName, nil]];
    [groupString appendAttributedString:nameString];
    return groupString;
}

- (void)postMessage{
    for (YMArt *art in [[YMProperty sharedInstance] selectedArts]) {
        id group = [self.groups objectAtIndex:self.selectedGroupIndex - 1];
        NSString *groupId = [group objectForKey:@"id"];
        if (groupId==nil) {
            groupId = @"0";
        }
        [YMNetwork uploadImage:art.image toGroup:groupId delegate:self];
    }
    
//    [SVProgressHUD show];
//    
//    id group = [self.groups objectAtIndex:self.selectedGroupIndex - 1];
//    NSString *groupId = [group objectForKey:@"id"];
//    if (groupId==nil) {
//        groupId = @"0";
//    }
//    NSString *postBody = self.textView.text;
//    
//    [YMNetwork postMessage:postBody toGroup:groupId forDelegate:self];
}

#pragma mark - YMNetworkDelegate Methods

- (void)groupsAvailable:(id)groups error:(NSError *)error{
    [SVProgressHUD dismiss];
    if (groups) {
        self.groups = groups;
    }
}

- (void)messageSentWithError:(NSError *)error{
    if (error) {
        [SVProgressHUD showErrorWithStatus:[error description]];
    }
    else{
        [SVProgressHUD showSuccessWithStatus:@"Sent"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
