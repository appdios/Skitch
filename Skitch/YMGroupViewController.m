//
//  YMGroupViewController.m
//  Skitch
//
//  Created by Aditi Kamal on 7/6/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMGroupViewController.h"

@interface YMGroupViewController ()

@property (nonatomic, strong) NSArray *groups;
@end

@implementation YMGroupViewController

- (id)initWithStyle:(UITableViewStyle)style andGroups:(id)groups
{
    self = [super initWithStyle:style];
    if (self) {
        self.groups = [NSArray arrayWithArray:groups];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"GroupCell"];
    self.navigationItem.title = @"Select group";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.groups count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"All Company";
    }
    else{
        id group = [self.groups objectAtIndex:indexPath.row - 1];
        id fullName = [group objectForKey:@"full_name"];
        cell.textLabel.text = fullName;
    }
    
    if (indexPath.row == self.selectedGroupIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.selectedGroupIndex) {
        return;
    }
    NSInteger lastSelectedIndex = self.selectedGroupIndex;
    self.selectedGroupIndex = indexPath.row;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:lastSelectedIndex inSection:0],[NSIndexPath indexPathForRow:self.selectedGroupIndex inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.delegate groupChangedToIndex:self.selectedGroupIndex];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
