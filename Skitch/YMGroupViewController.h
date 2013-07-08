//
//  YMGroupViewController.h
//  Skitch
//
//  Created by Aditi Kamal on 7/6/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMGroupSelectionDelegate <NSObject>

- (void)groupChangedToIndex:(NSInteger)index;

@end

@interface YMGroupViewController : UITableViewController

@property (nonatomic, weak) id<YMGroupSelectionDelegate> delegate;
@property (nonatomic) NSInteger selectedGroupIndex;

- (id)initWithStyle:(UITableViewStyle)style andGroups:(id)groups;
@end
