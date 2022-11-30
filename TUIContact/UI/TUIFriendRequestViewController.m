//
//  TUIFriendRequestViewController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/4/18.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//
#import "TUIFriendRequestViewController.h"
#import "UIView+TUILayout.h"
#import "TUICommonContactProfileCardCell.h"
#import "TUICommonModel.h"
#import "TUICommonContactSwitchCell.h"
#import "TUIContactAvatarViewController.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"
#import "MJNetWorkToolsOC.h"

@interface TUIFriendRequestViewController () <UITableViewDataSource, UITableViewDelegate>
@property UITableView *tableView;
@property UITextView  *addWordTextView;
@property UITextField *nickTextField;
@property UILabel *groupNameLabel;
@property BOOL keyboardShown;
@property TUICommonContactProfileCardCellData *cardCellData;
@property TUICommonContactSwitchCellData *singleSwitchData;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@end

@implementation TUIFriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.frame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }

    self.addWordTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.addWordTextView.font = [UIFont systemFontOfSize:14];

    NSString * selfUserID = [[V2TIMManager sharedInstance] getLoginUser];
    [[V2TIMManager sharedInstance] getUsersInfo:@[selfUserID] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            if (infoList && infoList.count > 0) {
                V2TIMUserFullInfo * userInfo = [infoList firstObject];
                if (userInfo) {
                    self.addWordTextView.text = [NSString stringWithFormat:TUIKitLocalizableString(FriendRequestFormat), userInfo.nickName?userInfo.nickName:userInfo.userID];
                }
            }
        } fail:^(int code, NSString *desc) {
            
        }];

    self.nickTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.nickTextField.textAlignment = NSTextAlignmentRight;


    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TUIKitLocalizableString(FriendRequestFillInfo)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";

    TUICommonContactProfileCardCellData *data = [TUICommonContactProfileCardCellData new];
    data.name = [self.profile showName];
    data.genderString = [self.profile showGender];
    data.identifier = self.profile.userID;
    data.signature =  [self.profile showSignature];
    data.avatarImage = DefaultAvatarImage;
    data.avatarUrl = [NSURL URLWithString:self.profile.faceURL];
    data.showSignature = YES;
    self.cardCellData = data;


    self.singleSwitchData = [TUICommonContactSwitchCellData new];
    self.singleSwitchData.title = TUIKitLocalizableString(FriendOneWay);


    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil]
      filter:^BOOL(NSNotification *value) {
          @strongify(self);
          return !self.keyboardShown;
      }]
     subscribeNext:^(NSNotification *x) {
         @strongify(self);
         self.keyboardShown = YES;
         [self adjustContentOffsetDuringKeyboardAppear:YES withNotification:x];
     }];

    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil]
      filter:^BOOL(NSNotification *value) {
          @strongify(self);
          return self.keyboardShown;
      }]
     subscribeNext:^(NSNotification *x) {
         @strongify(self);
         self.keyboardShown = NO;
         [self adjustContentOffsetDuringKeyboardAppear:NO withNotification:x];
     }];
}

#pragma mark - Keyboard
- (void)adjustContentOffsetDuringKeyboardAppear:(BOOL)appear withNotification:(NSNotification *)notification {
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardEndFrame);


    CGSize contentSize = self.tableView.contentSize;
    contentSize.height += appear? -keyboardHeight : keyboardHeight;

    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | curve animations:^{
        self.tableView.contentSize = contentSize;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0) {
        return [self.cardCellData heightOfWidth:Screen_Width];
    }
    if (indexPath.section == 1) {
        return 120;
    }
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1/1.0];
    label.font = [UIFont systemFontOfSize:14.0];
    if (section == 1) {
        label.text = [NSString stringWithFormat:@"   %@", TUIKitLocalizableString(please_fill_in_verification_information)];
    } else if (section == 2) {
        label.text = [NSString stringWithFormat:@"   %@", TUIKitLocalizableString(please_fill_in_remarks_group_info)];
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0 : 38;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TUICommonContactProfileCardCell *cell = [[TUICommonContactProfileCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TPersonalCommonCell_ReuseId"];
        cell.delegate = self;
        [cell fillWithData:self.cardCellData];
        return cell;
    }
    if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddWord"];
        [cell.contentView addSubview:self.addWordTextView];
        self.addWordTextView.mm_width(Screen_Width).mm_height(120);
        return cell;
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NickName"];
            cell.textLabel.text = TUIKitLocalizableString(Alia);
            [cell.contentView addSubview:self.nickTextField];
            
            UIView *separtor = [[UIView alloc] init];
            separtor.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [cell.contentView addSubview:separtor];
            separtor.mm_width(tableView.mm_w).mm_bottom(0).mm_left(0).mm_height(1);
            
            self.nickTextField.mm_width(cell.contentView.mm_w/2).mm_height(cell.contentView.mm_h).mm_right(20);
            self.nickTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            
            
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GroupName"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = TUIKitLocalizableString(Group);
            cell.detailTextLabel.text = TUIKitLocalizableString(my_friend);
            self.groupNameLabel = cell.detailTextLabel;
            
            UIView *separtor = [[UIView alloc] init];
            separtor.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [cell.contentView addSubview:separtor];
            separtor.mm_width(tableView.mm_w).mm_bottom(0).mm_left(0).mm_height(1);
            
            return cell;
        }
    }
    if (indexPath.section == 3) {
        TUIButtonCell *cell = [[TUIButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"send"];
        TUIButtonCellData *data = [[TUIButtonCellData alloc] init];
        data.style = ButtonWhite;
        data.title = TUIKitLocalizableString(Send);
        data.cselector = @selector(onSend);
        data.textColor = TUICoreDynamicColor(@"primary_theme_color", @"03BDAC"); //[UIColor colorWithRed:20/255.0 green:122/255.0 blue:255/255.0 alpha:1/1.0];
        [cell fillWithData:data];
        
        return cell;
    }

    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)onSend
{
    [self.view endEditing:YES];
    // display toast with an activity spinner
    [TUITool makeToastActivity];
    
    V2TIMFriendAddApplication *application = [[V2TIMFriendAddApplication alloc] init];
    application.addWording = self.addWordTextView.text;
    application.friendRemark = self.nickTextField.text;
    //application.group = self.groupNameLabel.text;
    application.userID = self.profile.userID;
    application.addSource = @"iOS";
    if (self.singleSwitchData.on) {
        application.addType = V2TIM_FRIEND_TYPE_SINGLE;
    } else {
        application.addType = V2TIM_FRIEND_TYPE_BOTH;
    }
    
    //添加好友
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    params[@"addSource"] = @"AddSource_Type_iOS";
    params[@"friendId"] = self.profile.userID;
    [MJNetWorkToolsOC postRequestBodyData:API_uacAddFriend params:params completeHandler:^(BOOL state, NSDictionary *result, NSString *msg, NSInteger code) {
        [TUITool hideToastActivity];
        if (state) {
            NSDictionary *resultDic = [result objectForKey:@"result"];
            NSDictionary *dataDic = [[resultDic objectForKey:@"resultItem"] firstObject];
            NSInteger resultCode = [[dataDic objectForKey:@"resultCode"] intValue];
            NSString *str = [self getAddFriendMsgWith:resultCode];
            [TUITool makeToast:str];
            if (resultCode == 0 || resultCode == 30539) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        } else {
            [TUITool makeToast:msg];
        }
    }];
    
//    [[V2TIMManager sharedInstance] addFriend:application succ:^(V2TIMFriendOperationResult *result) {
//        NSString *msg = nil;
//        if (ERR_SUCC == result.resultCode) {
//            msg = TUIKitLocalizableString(FriendAddResultSuccess);
//        }
//        else if (ERR_SVR_FRIENDSHIP_INVALID_PARAMETERS == result.resultCode) {
//            if ([result.resultInfo isEqualToString:@"Err_SNS_FriendAdd_Friend_Exist"]) {
//                msg = TUIKitLocalizableString(FriendAddResultExists);
//            }
//        }
//        else {
//            msg = [TUITool convertIMError:result.resultCode msg:result.resultInfo];
//        }
//
//        if (msg.length == 0) {
//            msg = [NSString stringWithFormat:@"%ld", (long)result.resultCode];
//        }
//
//        [TUITool hideToastActivity];
//        [TUITool makeToast:msg duration:3.0 idposition:TUICSToastPositionCenter];
//    } fail:^(int code, NSString *desc) {
//        [TUITool hideToastActivity];
//        [TUITool makeToastError:code msg:desc];
//    }];
}

- (NSString *)getAddFriendMsgWith:(NSInteger)errCode {
    NSString *str = @"添加好友异常";
    if (errCode == 0) {
        str = @"添加好友成功";
    } else if (errCode == 30539) {
        str = @"等待对方验证";
    } else if (errCode == 30010) {
        str = @"好友列表已达上限";
    } else if (errCode == 30014) {
        str = @"对方好友列表已达上限";
    } else if (errCode == 30516) {
        str = @"添加失败！您已被对方屏蔽";
    } else if (errCode == 30515) {
        str = @"添加失败！您将对方设为了黑名单";
    } else if (errCode == 30525) {
        str = @"你在对方黑名单中";
    } else if (errCode == 30003) {
        str = @"请求的用户账号不存在";
    }
    return str;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(void)didTapOnAvatar:(TUICommonContactProfileCardCell *)cell{
    TUIContactAvatarViewController *image = [[TUIContactAvatarViewController alloc] init];
    image.avatarData = cell.cardData;
    [self.navigationController pushViewController:image animated:YES];
}

@end
