//
//  HAYuYueDetailViewController.h
//  HZGHJ
//
//  Created by zhang on 16/12/12.
//  Copyright © 2016年 FiveFu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HAYuYueDetailViewController : UIViewController
@property(nonatomic,strong)NSString*reservationId;
@property(nonatomic,strong)NSDictionary*detailData;
@property(nonatomic,strong)NSMutableArray *dataList;
@property(nonatomic,assign)BOOL isMy;
@end
