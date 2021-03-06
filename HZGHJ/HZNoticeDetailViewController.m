//
//  HZNoticeDetailViewController.m
//  HZGHJ
//
//  Created by zhang on 16/12/13.
//  Copyright © 2016年 FiveFu. All rights reserved.
//

#import "HZNoticeDetailViewController.h"
#import "HZPictureViewController.h"
#import "MBProgressHUD.h"
#import "HZLoginService.h"
#import "HZURL.h"
#import "UIView+Toast.h"
#import "HZLoginViewController.h"

@interface HZNoticeDetailViewController ()<UIGestureRecognizerDelegate>{
    NSDictionary *returnData;
    NSDictionary *totalDic;
    UIScrollView* bgView;
      UIScrollView* bgScrollView;
    NSMutableArray *imageArray;//图片显示数组
    int numberOfArray;//图片显示数组
}

@end

@implementation HZNoticeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"返回"style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.title=@"消息详情";
    returnData=[[NSDictionary alloc]init];
     imageArray=[[NSMutableArray alloc]init];
    [self getResourceData];
    bgView=[[UIScrollView alloc]init];
    bgScrollView=[[UIScrollView alloc]init];
    
    bgScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, Width, Height-44)];
        bgScrollView.contentSize=CGSizeMake(Width,  Height-20);
    bgScrollView.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
    bgScrollView.userInteractionEnabled=YES;
    [self.view addSubview:bgScrollView];
//    [self addSubviews];
}
-(void)getResourceData{
    MBProgressHUD *hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text=@"数据加载中，请稍候...";
     [HZLoginService NoticeWithRecordId:self.recordid andBlock:^(NSDictionary *returnDic, NSError *error) {
         [hud hideAnimated:YES];
       if ([[returnDic objectForKey:@"code"]integerValue]==0) {
           totalDic=returnDic;
             returnData=[returnDic objectForKey:@"obj"];
              [self addSubviews];
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
       }else   if ([[returnDic objectForKey:@"code"]integerValue]==1000) {
           [self.view makeToast:[returnDic objectForKey:@"desc"]];
       }else{
           [self.view makeToast:@"请求不成功，请重新尝试"];
       }
     }];
}
-(void)addSubviews{
    UIView *topBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, Width, Height/17*6)];
    topBgView.backgroundColor=[UIColor  whiteColor];
    [bgScrollView addSubview:topBgView];
    NSArray *subArray=@[@"消息标题",@"项目编号",@"项目名称",@"建设单位",@"项目阶段",@"主办科室"];
    NSString *str1=[[returnData objectForKey:@"message"]objectForKey:@"title"];
    NSString *str2=[[returnData objectForKey:@"project"]objectForKey:@"realprojectid"];
    NSString *str3=[[returnData objectForKey:@"project"]objectForKey:@"projectName"];
    NSString *str4=[[returnData objectForKey:@"constructionunit"]objectForKey:@"name"];
    NSString *str5=[[returnData objectForKey:@"process"]objectForKey:@"name"];
    NSString *str6=[returnData objectForKey:@"hostdepartment"];
    if (str1==NULL||str1==nil)  str1=@"";
    if (str2==NULL||str2==nil)  str2=@"";
    if (str3==NULL||str3==nil)  str3=@"";
    if (str4==NULL||str4==nil)  str4=@"";
    if (str5==NULL||str5==nil)  str5=@"";
    if (str6==NULL||str6==nil)  str6=@"";
    
    NSArray *textArray=@[str1,str2,str3,str4,str5,str6];
    for (int i=0; i<6; i++) {
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, Height/17*i, 80, Height/17)];
        label.textAlignment=NSTextAlignmentRight;
        label.text=[subArray objectAtIndex:i];
        label.font=[UIFont systemFontOfSize:15];
        [topBgView addSubview:label];
        
        UILabel *line=[[UILabel alloc]initWithFrame:CGRectMake(81, Height/17*i+5, 1, Height/17-10)];
        line.backgroundColor=[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
        [topBgView addSubview:line];
        
        UILabel *text=[[UILabel alloc]initWithFrame:CGRectMake(85, Height/17*i, Width -85, Height/17)];
        text.textAlignment=NSTextAlignmentLeft;
        text.text=[textArray objectAtIndex:i];
        text.font=[UIFont systemFontOfSize:15];
        [topBgView addSubview:text];
    }
       NSString *str7=[[returnData objectForKey:@"message"]objectForKey:@"detail"];
     if (str7==NULL||str7==nil)  str7=@"";
    NSArray *textArray1=@[str4,str7];
    for (int i=0; i<2; i++) {
        UILabel *text=[[UILabel alloc]initWithFrame:CGRectMake(0, Height/17*6+Height/16+Height/8*i, Width , Height/16)];
        text.text=[NSString stringWithFormat:@"   %@",textArray1[i]];
        text.backgroundColor=[UIColor whiteColor];
        text.textAlignment=NSTextAlignmentLeft;
        text.font=[UIFont systemFontOfSize:15];
        [bgScrollView addSubview:text];
        if (i==1) {
            text.tag=10;
            text.numberOfLines=10;
            text.lineBreakMode = NSLineBreakByTruncatingTail;
            
            CGSize maximumLabelSize = CGSizeMake(Width-20, 160);//labelsize的最大值
            
            //关键语句
            
            CGSize expectSize = [text sizeThatFits:maximumLabelSize];
            
            //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
            
            text.frame = CGRectMake(0, Height/17*6+Height/16+Height/8*i, Width, expectSize.height+20);
//            topBgView.frame=CGRectMake(0, 40+80*i, Width, expectSize.height+20);
        }

    }
    NSArray *subArray1=@[@"推送对象",@"推送内容",@"附件(图片)信息"];
    for (int i=0; i<3; i++) {
        UILabel *text=[[UILabel alloc]initWithFrame:CGRectMake(25, Height/17*6+Height/8*i, 150, Height/16)];
        if (i==2) {
            UILabel *label=[self.view viewWithTag:10];
            text.frame=CGRectMake(25, label.frame.origin.y+label.frame.size.height+10, 150, Height/16);
            text.tag=11;
        }
        text.textAlignment=NSTextAlignmentLeft;
        text.text=[NSString stringWithFormat:@"   %@",[subArray1 objectAtIndex:i]];
        text.font=[UIFont systemFontOfSize:15];
        [bgScrollView addSubview:text];
        
    }

   NSInteger messageattachment=  [[returnData objectForKey:@"messageattachment"]integerValue];
    if (messageattachment==1||messageattachment==2||messageattachment==3) {
        [self addFuJian];
    }else if (messageattachment==5) {
        [self addPicture:0];
    }else{
            [self.view makeToast:@"没有图片数据"];
    }
}
-(void)addFuJian{
    NSArray *filelist=[totalDic objectForKey:@"list"];
    UILabel *label=[self.view viewWithTag:11];
    bgView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, Height/17*5+Height/8*3-Height/16+label.frame.size.height, Width, 210*filelist.count)];
    //    bgView.contentSize=CGSizeMake(Width, 210*filelist.count);
    bgView.backgroundColor=[UIColor whiteColor];
    bgView.userInteractionEnabled=YES;
    [bgScrollView addSubview:bgView];
    if (![filelist isEqual:[NSNull null]]&&filelist.count>0) {
        bgScrollView.contentSize=CGSizeMake(Width, Height-64+210*filelist.count);
        for (int i=0; i<filelist.count; i++) {
            UILabel*titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0+210*i, Width-40, 45)];
            titleLabel.textColor=[UIColor blackColor];
            titleLabel.numberOfLines=2;
            titleLabel.textAlignment=NSTextAlignmentLeft;
            titleLabel.font=[UIFont systemFontOfSize:16];
            [bgView addSubview:titleLabel];
            UILabel*subTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 45+210*i, Width-40, 20)];
            subTitle.textColor=[UIColor grayColor];
            subTitle.textAlignment=NSTextAlignmentLeft;
            subTitle.font=[UIFont systemFontOfSize:15];
            [bgView addSubview:subTitle];
            UILabel*nameTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 65+210*i, Width-40, 17)];
            nameTitle.textColor=[UIColor colorWithRed:23/255.0 green:177/255.0 blue:242/255.0 alpha:1];
            nameTitle.textAlignment=NSTextAlignmentLeft;
            nameTitle.font=[UIFont systemFontOfSize:15];
            [bgView addSubview:nameTitle];
            UILabel* phoneLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 82+210*i, Width-40, 17)];
            phoneLabel.textColor=[UIColor grayColor];
            phoneLabel.textAlignment=NSTextAlignmentLeft;
            phoneLabel.font=[UIFont systemFontOfSize:15];
            [bgView addSubview:phoneLabel];
            UILabel*timeTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 99+210*i, Width-40, 17)];
            timeTitle.textColor=[UIColor grayColor];
            timeTitle.textAlignment=NSTextAlignmentLeft;
            timeTitle.font=[UIFont systemFontOfSize:15];
            [bgView addSubview:timeTitle];
            UILabel*statusLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 116+210*i, Width-40, 20)];
            statusLabel.textAlignment=NSTextAlignmentLeft;
            statusLabel.font=[UIFont systemFontOfSize:15];
            statusLabel.textColor=[UIColor blackColor];
            [bgView addSubview:statusLabel];
            
            NSDictionary *dic=[filelist objectAtIndex:i];
            titleLabel.text=[NSString stringWithFormat:@"%@",[[dic objectForKey:@"dbAProject"]objectForKey:@"projectName"]];
            
            subTitle.text=[NSString stringWithFormat:@"项目地址  %@",[[dic objectForKey:@"dbAProject"]objectForKey:@"residentiaAddress"]];
            nameTitle.text=[NSString stringWithFormat:@"项目阶段  %@",[[dic objectForKey:@"dbAProcess"]objectForKey:@"name"]];
            NSString*str=[dic objectForKey:@"uploadtime"];//时间戳
            NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:[str integerValue]/1000];
            
            //实例化一个NSDateFormatter对象
            
            NSDateFormatter*dateFormatter = [[NSDateFormatter alloc]init];
            
            //设定时间格式,这里可以设置成自己需要的格式
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSString*currentDateStr = [dateFormatter stringFromDate:detaildate];
            phoneLabel.text=[NSString stringWithFormat:@"上报人 : %@   上报日期:  %@",[[dic objectForKey:@"dbSysAdmin"]objectForKey:@"name"],currentDateStr];
            timeTitle.text=[NSString stringWithFormat:@"文字信息: "];
            statusLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"detail"]];
            
            [self addPicture:i];
        }
    }else{
        [self.view makeToast:@"没有图片数据"];
    }
}
-(void)addPicture:(int)number{
    NSInteger messageattachment=  [[returnData objectForKey:@"messageattachment"]integerValue];
     UILabel *label=[self.view viewWithTag:11];
    if (messageattachment==1||messageattachment==2||messageattachment==3) {
        NSArray *listArray=[totalDic objectForKey:@"list"];
        NSDictionary *listDic=[listArray objectAtIndex:number];
        NSLog(@"listDic   %@    number  %d",listDic,number);
        NSArray *filelist=[listDic objectForKey:@"filelist"];
        if (![filelist isEqual:[NSNull null]]&&filelist.count>0) {
            for (int i=0; i<filelist.count; i++) {
                NSString *url=[NSString stringWithFormat:@"%@%@?fileId=%@",kDemoBaseURL,kGetFileURL,[[filelist objectAtIndex:i]objectForKey:@"id"]];
                UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(20+100*i, 140+210*(number/3), 70, 70)];
                imageView.userInteractionEnabled=YES;
                //    NSLog(@"url  %@",url);
                [imageView sd_setImageWithURL:[NSURL URLWithString:url]placeholderImage:[UIImage imageNamed:@"img_default"]];
                
                UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
                tap.accessibilityValue=[NSString stringWithFormat:@"%d-%@",number,url];
                tap.delegate=self;
                [imageView addGestureRecognizer:tap];
                
                bgView.contentSize=CGSizeMake(100*imageArray.count, 70);
                [bgView addSubview:imageView];
            }
        }else{
              [self.view makeToast:@"没有图片数据"];
        }
        
        
    }else if (messageattachment==5) {
        NSArray *listArray=[totalDic objectForKey:@"listfiles"];
        if (![listArray isEqual:[NSNull null]]&&listArray.count>0) {
            imageArray=[[NSMutableArray alloc]init];
            for (int i=0; i<listArray.count; i++) {
                NSDictionary *listDic=[listArray objectAtIndex:i];
                NSString *url=[NSString stringWithFormat:@"%@%@?fileId=%@",kDemoBaseURL,kGetFileURL,[listDic objectForKey:@"id"]];
                [imageArray addObject:url];
                UIImageView*imageView=[[UIImageView alloc]init];
                bgView.frame=CGRectMake(0, label.frame.origin.y+label.frame.size.height+10, Width, 70+100*(listArray.count-1)/3);
                bgView.contentSize=CGSizeMake(100*imageArray.count, 70);
                [bgScrollView addSubview:bgView];
                imageView.frame=CGRectMake(20+100*i, 0, 70, 70);
                [bgView addSubview:imageView];
                imageView.userInteractionEnabled=YES;
                NSLog(@"url  %@",url);
                [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"img_default"]];
                
                UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
                tap.accessibilityValue=[NSString stringWithFormat:@"%@",url];
                tap.delegate=self;
                [imageView addGestureRecognizer:tap];
                [bgView addSubview:imageView];
            }
        }else{
            [self.view makeToast:@"没有图片数据"];
        }
        
    }
}
-(void)tap:(UITapGestureRecognizer*)tap{
    NSInteger messageattachment=  [[returnData objectForKey:@"messageattachment"]integerValue];
    NSString *nowUrl;
    if (messageattachment==1||messageattachment==2||messageattachment==3) {
        NSArray *array=[tap.accessibilityValue componentsSeparatedByString:@"-"];
        int number=[array[0] intValue];
        nowUrl=array[1];
        NSArray *listArray=[totalDic objectForKey:@"list"];
        NSDictionary *listDic=[listArray objectAtIndex:number];
        NSLog(@"listDic   %@    number  %d",listDic,number);
        NSArray *filelist=[listDic objectForKey:@"filelist"];
        if (![filelist isEqual:[NSNull null]]&&filelist.count>0) {
            imageArray=[[NSMutableArray alloc]init];
            for (int i=0; i<filelist.count; i++) {
                NSString *url=[NSString stringWithFormat:@"%@%@?fileId=%@",kDemoBaseURL,kGetFileURL,[[filelist objectAtIndex:i]objectForKey:@"id"]];
                //    NSLog(@"url  %@",url);
                [imageArray addObject:url];
            }
        }
        
        
    }else if (messageattachment==5) {
        nowUrl=tap.accessibilityValue;
        NSArray *listArray=[totalDic objectForKey:@"listfiles"];
        if (![listArray isEqual:[NSNull null]]&&listArray.count>0) {
            imageArray=[[NSMutableArray alloc]init];
            for (int i=0; i<listArray.count; i++) {
                NSDictionary *listDic=[listArray objectAtIndex:i];
                NSString *url=[NSString stringWithFormat:@"%@%@?fileId=%@",kDemoBaseURL,kGetFileURL,[listDic objectForKey:@"id"]];
                [imageArray addObject:url];
            }
        }
        
    }

    HZPictureViewController *picture=[[HZPictureViewController alloc]init];
    picture.isWeb=NO;
    picture.imageArray=imageArray;
    NSInteger index=[imageArray indexOfObject:nowUrl];
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
