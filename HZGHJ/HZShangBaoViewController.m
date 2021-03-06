//
//  HZShangBaoViewController.m
//  HZGHJ
//
//  Created by zhang on 16/12/9.
//  Copyright © 2016年 FiveFu. All rights reserved.
//

#import "HZShangBaoViewController.h"
#import "MBProgressHUD.h"
#import "SVPullToRefresh.h"
#import "HZLoginService.h"
#import "HZProjectViewController.h"
#import "UIImageView+WebCache.h"
#import "HZPictureViewController.h"
#import "HZURL.h"
#import "UIView+Toast.h"
#import "HZLoginViewController.h"

@interface HZShangBaoViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    int pageIndex;
    UITableView *tableview;
    UISegmentedControl *segmented;
    UIButton *pos;
}


@end

@implementation HZShangBaoViewController
@synthesize dataList;
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
      [self getDataSource];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     self.navigationController.navigationBarHidden=NO;
    self.view.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"返回"style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.title=@"过程上报";
    pos = [[UIButton alloc] initWithFrame                                                                      :CGRectMake(15, 5, 80, 20)];
    [pos setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    [pos addTarget:self action:@selector(shangbao) forControlEvents:UIControlEventTouchUpInside];
    [pos setTitle:@"项目上报" forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:pos];
    self.navigationItem.rightBarButtonItem = leftItem;
    
    pageIndex=1;
    dataList=[[NSMutableArray alloc]init];
    tableview=[[UITableView alloc]initWithFrame:CGRectMake(0, 55, Width, Height-44-55)];
    [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableview.delegate=self;
    tableview.separatorColor=[UIColor clearColor];
    tableview.dataSource=self;
    [self.view addSubview:tableview];
  
    NSArray *titleArray=@[@"过程上报",@"我的上报"];
    segmented=[[UISegmentedControl alloc]initWithItems:titleArray];
     [segmented setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
    segmented.frame=CGRectMake(5, 5, Width-10, 40);
    segmented.selectedSegmentIndex=0;
    [segmented addTarget:self action:@selector(choseSeg:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmented];
    __weak HZShangBaoViewController *yuyue=self;
    [tableview addInfiniteScrollingWithActionHandler:^{
        pageIndex=pageIndex+1;
        [yuyue getDataSource];
    }];
    [tableview addPullToRefreshWithActionHandler:^{
        pageIndex=1;
        [yuyue getDataSource];
    }];
    [tableview.pullToRefreshView setTitle:@"下拉以刷新" forState:SVPullToRefreshStateTriggered];
    [tableview.pullToRefreshView setTitle:@"刷新完了哟" forState:SVPullToRefreshStateStopped];
    [tableview.pullToRefreshView setTitle:@"不要命的加载中..." forState:SVPullToRefreshStateLoading];

}
-(void)shangbao{
    HZProjectViewController *shangbao=[[HZProjectViewController alloc]init];
    [self.navigationController pushViewController:shangbao animated:YES];
}
-(void)getDataSource{
    MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text=@"数据提交中，请稍候...";
    [tableview.infiniteScrollingView stopAnimating];
    [tableview.pullToRefreshView stopAnimating];
    NSString *token=[[NSUserDefaults standardUserDefaults]objectForKey:@"token"];
    if (segmented.selectedSegmentIndex==0) {
        [HZLoginService ShangBaoWithToken:token pageIndex:pageIndex andBlock:^(NSDictionary *returnDic, NSError *error) {
            [hud hideAnimated:YES];
            if ([[returnDic objectForKey:@"code"]integerValue]==0) {
                NSArray *array=[returnDic objectForKey:@"list"];
                if (pageIndex==1) {
                    dataList=[NSMutableArray                                                                                                                                                                                                                                                                                                                                           arrayWithArray:array];
                }else{
                    [dataList addObjectsFromArray:array];
                }
                if (dataList.count>0){
                    
                                 }else{
                                     [self.view makeToast:@"您的过程上报暂无数据"];
                }
//                NSData *data =    [NSJSONSerialization dataWithJSONObject:returnDic options:NSJSONWritingPrettyPrinted error:nil];
//                NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                [tableview reloadData];
//                NSLog(@"过程上报列表    %@  %@",str,returnDic);
                
            }else   if ([[returnDic objectForKey:@"code"]integerValue]==900) {
                UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"您的账号已被其他设备登陆，请重新登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAlert=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    HZLoginViewController *login=[[HZLoginViewController alloc]init];
                    [self.navigationController pushViewController:login animated:YES];
                }];
                [alert addAction:okAlert];
                UIAlertAction *cancelAlert=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alert addAction:cancelAlert];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else   if ([[returnDic objectForKey:@"code"]integerValue]==1000) {
                 [self.view makeToast:[returnDic objectForKey:@"desc"]];
            }else{
                [self.view makeToast:@"请求不成功"];
            }

        }];
    }else{
        [HZLoginService WoDeShangBaoWithToken:token pageIndex:pageIndex andBlock:^(NSDictionary *returnDic, NSError *error) {
            [hud hideAnimated:YES];
            if ([[returnDic objectForKey:@"code"]integerValue]==0) {
                NSArray *array=[returnDic objectForKey:@"list"];
                if (pageIndex==1) {
                    dataList=[NSMutableArray                                                                                                                                                                                                                                                                                                                                           arrayWithArray:array];
                }else{
                    [dataList addObjectsFromArray:array];
                }
                if (dataList.count>0){
                    
                }else{
                    [self.view makeToast:@"您的过程上报暂无数据"];
                }
                [tableview reloadData];
            }else   if ([[returnDic objectForKey:@"code"]integerValue]==900) {
                UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"您的账号已被其他设备登陆，请重新登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAlert=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    HZLoginViewController *login=[[HZLoginViewController alloc]init];
                    [self.navigationController pushViewController:login animated:YES];
                }];
                [alert addAction:okAlert];
                UIAlertAction *cancelAlert=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alert addAction:cancelAlert];
                [self presentViewController:alert animated:YES completion:nil];
            }   else   if ([[returnDic objectForKey:@"code"]integerValue]==1000) {
                [self.view makeToast:[returnDic objectForKey:@"desc"]];
            }else{
                [self.view makeToast:@"请求不成功"];
            }

            [tableview reloadData];
            NSLog(@"我的过程    %@",returnDic);
        }];
    }
    
}
-(void)choseSeg:(UISegmentedControl *)segmented{
    pageIndex=1;
    [self getDataSource];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic=[dataList objectAtIndex:indexPath.row];
    NSArray *array=[dic objectForKey:@"filelist"];
    CGFloat height;
    if (array.count<4) {
        height=230;
    }else{
        height=320;
    }
    return height;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell=[[UITableViewCell alloc]init];
    }else{
        for (UIView *subView in cell.contentView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
 
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
    UIView* bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, Width, 225)];
    bgView.backgroundColor=[UIColor whiteColor];
    bgView.userInteractionEnabled=YES;
    [cell.contentView addSubview:bgView];
    UILabel*titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, Width-40, 45)];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.numberOfLines=2;
    titleLabel.textAlignment=NSTextAlignmentLeft;
    titleLabel.font=[UIFont systemFontOfSize:16];
    [bgView addSubview:titleLabel];
    UILabel*subTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 45, Width-40, 20)];
    subTitle.textColor=[UIColor grayColor];
    subTitle.textAlignment=NSTextAlignmentLeft;
    subTitle.font=[UIFont systemFontOfSize:15];
    [bgView addSubview:subTitle];
    UILabel*nameTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 65, Width-40, 17)];
    nameTitle.textColor=[UIColor colorWithRed:23/255.0 green:177/255.0 blue:242/255.0 alpha:1];
    nameTitle.textAlignment=NSTextAlignmentLeft;
    nameTitle.font=[UIFont systemFontOfSize:15];
    [bgView addSubview:nameTitle];
    UILabel* phoneLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 82, Width-40, 17)];
    phoneLabel.textColor=[UIColor grayColor];
    phoneLabel.textAlignment=NSTextAlignmentLeft;
    phoneLabel.font=[UIFont systemFontOfSize:15];
    [bgView addSubview:phoneLabel];
    UILabel*timeTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 99, Width-40, 17)];
    timeTitle.textColor=[UIColor grayColor];
    timeTitle.textAlignment=NSTextAlignmentLeft;
    timeTitle.font=[UIFont systemFontOfSize:15];
    [bgView addSubview:timeTitle];
    UILabel*statusLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 116, Width-40, 20)];
    statusLabel.textAlignment=NSTextAlignmentLeft;
    statusLabel.font=[UIFont systemFontOfSize:15];
    statusLabel.textColor=[UIColor blackColor];
    [bgView addSubview:statusLabel];
    
    NSDictionary *dic=[dataList objectAtIndex:indexPath.row];
    titleLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"projectName"]];
    
    subTitle.text=[NSString stringWithFormat:@"项目地址  %@",[[dic objectForKey:@"dbAProject"]objectForKey:@"residentiaAddress"]];
    nameTitle.text=[NSString stringWithFormat:@"项目阶段  %@",[dic objectForKey:@"processName"]];
    NSString*str=[[dic objectForKey:@"dbAUser"]objectForKey:@"createtime"];//时间戳
    NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:[str integerValue]/1000];
    
    //实例化一个NSDateFormatter对象
    
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc]init];
    
    //设定时间格式,这里可以设置成自己需要的格式
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString*currentDateStr = [dateFormatter stringFromDate:detaildate];
    phoneLabel.text=[NSString stringWithFormat:@"上报人 : %@   上报日期:  %@",[[dic objectForKey:@"dbAUser"]objectForKey:@"name"],currentDateStr];
    timeTitle.text=[NSString stringWithFormat:@"文字信息: "];
    statusLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"details"]];
    NSArray *array=[[NSArray alloc]init];
    array=[dic objectForKey:@"filelist"];
    if (array.count<4) {
        bgView.frame=CGRectMake(0, 0, Width, 225);
    }else{
        bgView.frame=CGRectMake(0, 0, Width, 315);
    }
    if (array!=NULL) {
        for (int i=0; i<array.count; i++) {
            UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(20+90*(i%3), 140+80*(i/3), 70, 70)];
            imageView.userInteractionEnabled=YES;
            NSDictionary *imageDic=[array objectAtIndex:i];
            NSString *url=[NSString stringWithFormat:@"%@%@?fileId=%@",kDemoBaseURL,kGetFileURL,[imageDic objectForKey:@"id"]];
            NSLog(@"url  %@",url);
            [imageView sd_setImageWithURL:[NSURL URLWithString:url]placeholderImage:[UIImage imageNamed:@"img_default"]];
            [bgView addSubview:imageView];
            
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
            tap.accessibilityValue=[NSString stringWithFormat:@"%ld-%@",indexPath.row,url];
            tap.delegate=self;
            [imageView addGestureRecognizer:tap];
        }
    }
   
    return cell;
}
-(void)tap:(UITapGestureRecognizer*)tap{
    NSArray *array=[tap.accessibilityValue componentsSeparatedByString:@"-"];
    HZPictureViewController *picture=[[HZPictureViewController alloc]init];
    picture.isWeb=NO;
    NSString *str1=array[0];
    NSString *str2=array[1];
    NSInteger number=[str1 integerValue];
    NSDictionary *dic=[dataList objectAtIndex:number];
    NSMutableArray *imageArray=[[NSMutableArray alloc]init];
    if ([dic objectForKey:@"filelist"]!=NULL) {
        NSArray *array=[dic objectForKey:@"filelist"];
        for (int i=0; i<array.count; i++) {
            NSDictionary *imageDic=[array objectAtIndex:i];
            NSString *url=[NSString stringWithFormat:@"%@%@?fileId=%@",kDemoBaseURL,kGetFileURL,[imageDic objectForKey:@"id"]];
            [imageArray addObject:url];
        }
    }
    picture.imageArray=imageArray;
    NSInteger index=[imageArray indexOfObject:str2];
    picture.indexOfImage=index;
    [self.navigationController pushViewController:picture animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
