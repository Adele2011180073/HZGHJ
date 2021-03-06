//
//  HZGongShiViewController.m
//  HZGHJ
//
//  Created by zhang on 16/12/9.
//  Copyright © 2016年 FiveFu. All rights reserved.
//

#import "HZGongShiViewController.h"
#import "HZGongShiListViewController.h"
#import "MBProgressHUD.h"
#import "SVPullToRefresh.h"
#import "HZLoginService.h"
#import "HZGongShiDetailViewController.h"
#import "UIView+Toast.h"
#import "HZLoginViewController.h"

@interface HZGongShiViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int pageIndex;
    UITableView *tableview;
    UISegmentedControl *segmented;
    UIButton *pos;
    NSString *projectname;
    NSArray *labelArray;
}


@end

@implementation HZGongShiViewController
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
    self.title=@"公示登记";
    pos = [[UIButton alloc] initWithFrame                                                                      :CGRectMake(15, 5, 80, 20)];
    [pos setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    [pos addTarget:self action:@selector(shangbao) forControlEvents:UIControlEventTouchUpInside];
    [pos setTitle:@"公示记录" forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:pos];
    self.navigationItem.rightBarButtonItem = leftItem;
    
    labelArray=[[NSArray alloc]initWithObjects:@"项目名称",@"起始日",@"时间一",@"时间二",@"结束日", nil];
    UILabel *imageTitle=[[UILabel alloc]initWithFrame:CGRectMake(30, 5, 40, 40)];
    imageTitle.textColor=blueCyan;
    imageTitle.font=[UIFont fontWithName:@"iconfont" size:36];
    imageTitle.text=@"\U0000e615";
    imageTitle.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:imageTitle];
        UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(80, 15, Width-100, 20)];
        title.textColor=[UIColor blackColor];
        title.font=[UIFont systemFontOfSize:16];
        title.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"department"];
        title.textAlignment=NSTextAlignmentLeft;
        [self.view addSubview:title];
    pageIndex=1;
    dataList=[[NSMutableArray alloc]init];
    tableview=[[UITableView alloc]initWithFrame:CGRectMake(0, 55, Width, Height-44-55)];
    [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableview.rowHeight=50;
    tableview.delegate=self;
//    tableview.separatorColor=[UIColor clearColor];
    tableview.dataSource=self;
     tableview.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableview];
    [self getDataSource];
    __weak HZGongShiViewController *yuyue=self;
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
    HZGongShiListViewController *shangbao=[[HZGongShiListViewController alloc]init];
    if (!projectname||projectname==NULL){[self.view makeToast:@"您的账户暂时无公示记录"];   return;}
    else{
        shangbao.projectname=projectname;
    [self.navigationController pushViewController:shangbao animated:YES];
    }
}
-(void)getDataSource{
    MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text=@"数据加载中，请稍候...";
    [tableview.infiniteScrollingView stopAnimating];
    [tableview.pullToRefreshView stopAnimating];
    NSString *token=[[NSUserDefaults standardUserDefaults]objectForKey:@"token"];
    [HZLoginService GongShiWithToken:token pageIndex:pageIndex                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    andBlock:^(NSDictionary *returnDic, NSError *error) {
            [hud hideAnimated:YES];
            if ([[returnDic objectForKey:@"code"]integerValue]==0) {
                NSArray *array=[returnDic objectForKey:@"list"];
//                if (pageIndex==1) {
                    dataList=[NSMutableArray                                                                                                                                                                                                                                                                                                                                           arrayWithArray:array];
//                }else{
//                    [dataList addObjectsFromArray:array];
//                }

                    NSDictionary *smallDic=[dataList objectAtIndex:0];
                    projectname=[smallDic objectForKey:@"projectname"];
                [tableview reloadData];
                NSLog(@"公示登记列表    %@  %d",array,dataList.count);
            }else   if ([[returnDic objectForKey:@"code"]integerValue]==900) {
                if (pageIndex==1) {
                    dataList=[[NSMutableArray alloc]init];
                }
                [tableview reloadData];
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
                [self.view makeToast:@"请求不成功，请重新尝试"];
            }
        }];
    }
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
     return dataList.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell=[[UITableViewCell alloc]init];
    }
     cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
    UIView* bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, Width, 50)];
    bgView.backgroundColor=[UIColor whiteColor];
    [cell.contentView addSubview:bgView];
    NSDictionary *dic=[dataList objectAtIndex:indexPath.section];
    UILabel*titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 15)];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.numberOfLines=1;
    titleLabel.textAlignment=NSTextAlignmentLeft;
    titleLabel.font=[UIFont systemFontOfSize:15];
    [bgView addSubview:titleLabel];
    titleLabel.text=[labelArray objectAtIndex:indexPath.row];
    if (indexPath.row==0) {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
         cell.accessoryType = UITableViewCellAccessoryNone;
       
        UILabel*titleText=[[UILabel alloc]initWithFrame:CGRectMake(120, 0, Width-130, 50)];
        titleText.textColor=[UIColor blackColor];
        titleText.numberOfLines=2;
        titleText.textAlignment=NSTextAlignmentLeft;
        titleText.font=[UIFont systemFontOfSize:16];
        [bgView addSubview:titleText];
        
        titleText.text=[dic objectForKey:@"projectname"];
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
       
        UILabel*imageText=[[UILabel alloc]initWithFrame:CGRectMake(120, 0, 60, 50)];
        imageText.text=@"\U0000e641";
        imageText.textColor=[UIColor grayColor];
        imageText.textAlignment=NSTextAlignmentCenter;
        imageText.font=[UIFont fontWithName:@"iconfont" size:36];
        [bgView addSubview:imageText];
        
        UILabel*titleText=[[UILabel alloc]initWithFrame:CGRectMake(180, 0, Width-190, 50)];
        titleText.textColor=[UIColor blackColor];
        titleText.textAlignment=NSTextAlignmentLeft;
        titleText.font=[UIFont systemFontOfSize:15];
        [bgView addSubview:titleText];
        imageText.textColor=[UIColor grayColor];
        titleText.text=@"未公示";
        NSArray *array=[dic objectForKey:@"publiclist"];
        if (array.count>0) {
            for (int i=0; i<array.count; i++) {
                NSDictionary *typeDic=[array objectAtIndex:i];
                
                if ([[typeDic objectForKey:@"type"]isEqualToString:@"1"]) {
                    NSString*str=[typeDic objectForKey:@"createtime"];//时间戳
                    NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:[str integerValue]/1000];
                    
                    //实例化一个NSDateFormatter对象
                    
                    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc]init];
                    
                    //设定时间格式,这里可以设置成自己需要的格式
                    
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSString*currentDateStr = [dateFormatter stringFromDate:detaildate];
                    if (indexPath.row==1) {
                        imageText.textColor=blueCyan;
                        cell.accessibilityValue=[NSString stringWithFormat:@"%d",1];
                        titleText.text=currentDateStr;
                    }else{
//                        imageText.textColor=[UIColor grayColor];
//                        titleText.text=@"未公示";
                    }
                }else  if ([[typeDic objectForKey:@"type"]isEqualToString:@"2"]) {
                    NSString*str=[typeDic objectForKey:@"createtime"];//时间戳
                    NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:[str integerValue]/1000];
                    
                    //实例化一个NSDateFormatter对象
                    
                    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc]init];
                    
                    //设定时间格式,这里可以设置成自己需要的格式
                    
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    
                    NSString*currentDateStr = [dateFormatter stringFromDate:detaildate];
                    if (indexPath.row==4) {
                        imageText.textColor=blueCyan;
                        titleText.text=currentDateStr;
                        cell.accessibilityValue=[NSString stringWithFormat:@"%d",1];
                    }else{
//                         imageText.textColor=[UIColor grayColor];
//                        titleText.text=@"未公示";
                    }
                }else  if ([[typeDic objectForKey:@"type"]isEqualToString:@"3"]) {
                    NSString*str=[typeDic objectForKey:@"createtime"];//时间戳
                    NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:[str integerValue]/1000];
                    
                    //实例化一个NSDateFormatter对象
                    
                    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc]init];
                    
                    //设定时间格式,这里可以设置成自己需要的格式
                    
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    
                    NSString*currentDateStr = [dateFormatter stringFromDate:detaildate];
                    if (indexPath.row==2) {
                        imageText.textColor=blueCyan;
                        titleText.text=currentDateStr;
                        cell.accessibilityValue=[NSString stringWithFormat:@"%d",1];
                    }
                    else{
//                        imageText.textColor=[UIColor grayColor];
//                        titleText.text=@"未公示";
                    }
                }else  if ([[typeDic objectForKey:@"type"]isEqualToString:@"4"]) {
                    NSString*str=[typeDic objectForKey:@"createtime"];//时间戳
                    NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:[str integerValue]/1000];
                    
                    //实例化一个NSDateFormatter对象
                    
                    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc]init];
                    
                    //设定时间格式,这里可以设置成自己需要的格式
                    
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    
                    NSString*currentDateStr = [dateFormatter stringFromDate:detaildate];
                    if (indexPath.row==3) {
                        imageText.textColor=blueCyan;
                        titleText.text=currentDateStr;
                        cell.accessibilityValue=[NSString stringWithFormat:@"%d",1];
                    }else{
//                        imageText.textColor=[UIColor grayColor];
//                        titleText.text=@"未公示";
                    }
                }
            }
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HZGongShiDetailViewController *detail=[[HZGongShiDetailViewController alloc]init];
    NSDictionary *dic=[dataList objectAtIndex:indexPath.section];
    NSArray *array=[dic objectForKey:@"publiclist"];
    if (array.count>0) {
        for (int i=0; i<array.count; i++) {
            NSDictionary *typeDic=[array objectAtIndex:i];
            if ([[typeDic objectForKey:@"type"]integerValue]==1) {
                if (indexPath.row==1) {
                     detail.isGongShi=YES;
                    detail.publicid=[typeDic objectForKey:@"id"];
                    detail.listDic=dic;
                }
            }
                if ([[typeDic objectForKey:@"type"]integerValue]==2) {
                    if (indexPath.row==4) {
                        detail.isGongShi=YES;
                        detail.publicid=[typeDic objectForKey:@"id"];
                       detail.listDic=dic;
                    }
                }  if ([[typeDic objectForKey:@"type"]integerValue]==3) {
                    if (indexPath.row==2) {
                        detail.isGongShi=YES;
                        detail.publicid=[typeDic objectForKey:@"id"];
                        detail.listDic=dic;
                    }
                }
                if ([[typeDic objectForKey:@"type"]integerValue]==4) {
                    if (indexPath.row==3) {
                        detail.isGongShi=YES;
                        detail.publicid=[typeDic objectForKey:@"id"];
                        detail.listDic=dic;
                    }
                }
        }
    }
    NSInteger type;
    switch (indexPath.row) {
        case 1:
            type=1;
            break;
        case 2:
            type=3;
            break;
        case 3:
            type=4;
            break;
        case 4:
            type=2;
            break;
        default:
            break;
    }
        detail.type=type;
        if (detail.isGongShi==NO) {
            detail.listDic=dic;
        }
       [self.navigationController pushViewController:detail animated:YES];
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
