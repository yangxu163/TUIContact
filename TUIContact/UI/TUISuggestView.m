//
//  TUISuggestView.m
//  TUIContact
//
//  Created by MuJI on 2022/11/10.
//

#import "TUISuggestView.h"
#import "UIColor+TUIHexColor.h"
#import "TUITool.h"
#import "MJNetWorkToolsOC.h"

static const NSInteger kMaxTextViewLength = 500;

@interface TUISuggestView () <UITextViewDelegate>
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeHolderLabel;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *sureBtn;

@end

@implementation TUISuggestView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
            
    }
    return self;
}

- (void)setupView {
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBgView)];
    [self.bgView addGestureRecognizer:tap];
    [self addSubview:self.bgView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 227)];
    self.contentView.center = self.bgView.center;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    [self.bgView addSubview:self.contentView];
    
    self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 280 - 12 * 2, 25)];
    self.titleLab.text = @"投诉";
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab.textColor = [UIColor colorWithHex:@"0x333333"];
    self.titleLab.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.contentView addSubview:self.titleLab];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 49, 280 - 12 * 2, 108)];
    self.textView.layer.cornerRadius = 4;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderColor = [UIColor colorWithHex:@"E5E5E5"].CGColor;
    self.textView.layer.borderWidth = 1;
    self.textView.delegate = self;
    [self.contentView addSubview:self.textView];
    
    self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 4.5, 256 - 4, 21)];
    self.placeHolderLabel.text = @"请输入投诉内容";
    self.placeHolderLabel.textColor = [UIColor colorWithHex:@"0xCCCCCC"];
    self.placeHolderLabel.font = [UIFont systemFontOfSize:15];
    [self.textView addSubview:self.placeHolderLabel];
    
    UIView *hLine = [[UIView alloc] initWithFrame:CGRectMake(0, 177, 280, 1)];
    hLine.backgroundColor = [UIColor colorWithHex:@"E5E5E5"];
    [self.contentView addSubview:hLine];
    
    UIView *vline = [[UIView alloc] initWithFrame:CGRectMake(280 / 2, 178, 1, 49)];
    vline.backgroundColor = [UIColor colorWithHex:@"E5E5E5"];
    [self.contentView addSubview:vline];
    
    self.cancelBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.cancelBtn.frame = CGRectMake(0, 178, 280 / 2, 49);
    [self.cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
    [self.cancelBtn setTitleColor:[UIColor colorWithHex:@"0x0FC6C2"] forState:(UIControlStateNormal)];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.cancelBtn addTarget:self action:@selector(cancelEvnet:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.contentView addSubview:self.cancelBtn];
    
    self.sureBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.sureBtn.frame = CGRectMake(280 / 2, 178, 280 / 2, 49);
    [self.sureBtn setTitle:@"确认" forState:(UIControlStateNormal)];
    [self.sureBtn setTitleColor:[UIColor colorWithHex:@"0x0FC6C2"] forState:(UIControlStateNormal)];
    self.sureBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.sureBtn addTarget:self action:@selector(sureEvnet:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.contentView addSubview:self.sureBtn];
    
}

- (void)cancelEvnet:(UIButton *)btn {
    [self.textView resignFirstResponder];
    [self hideView];
}

- (void)sureEvnet:(UIButton *)btn {
    [self.textView resignFirstResponder];
    
    [self requestSuggest];
}

- (void)showView {
    self.hidden = NO;
}

- (void)hideView {
    self.hidden = YES;
}

- (void)clickBgView {
    [self.textView resignFirstResponder];
}

///网络
- (void)requestSuggest {
    if (self.textView.text.length == 0) {
        [TUITool makeToast:@"请输入内容"];
        return;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    [params setValue:self.textView.text forKey:@"content"];
    
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *timeStr = [dateFmt stringFromDate:[NSDate date]];
    [params setValue:timeStr forKey:@"commitComplaintTime"];
    
    [MJNetWorkToolsOC postRequestBodyData:API_uacComplainAdviceSave params:params completeHandler:^(BOOL state, NSDictionary *result, NSString *msg, NSInteger code) {
        if (state) {
            [TUITool makeToast:@"提交成功"];
            [self hideView];
        } else {
            [TUITool makeToast:msg];
        }
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        self.placeHolderLabel.hidden = YES;
    } else {
        self.placeHolderLabel.hidden = NO;
    }
    
    if (textView.text.length > kMaxTextViewLength) {
        self.textView.text = [self.textView.text substringToIndex:kMaxTextViewLength];
    }
}

#pragma mark - 键盘
-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.25 animations:^{
        //恢复原样
        self.contentView.transform = CGAffineTransformIdentity;
    }];
}

-(void)keyboardWillShow:(NSNotification *)notification {
    //获得通知中的info字典
    NSDictionary *userInfo = [notification userInfo];
    CGRect rect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    CGRect contentFrame = self.contentView.frame;
    CGFloat maxY = CGRectGetMaxY(contentFrame);
    
    if (maxY + rect.size.height > self.bounds.size.height) {
        CGFloat offset = maxY + rect.size.height - self.bounds.size.height + 20;
        [UIView animateWithDuration:0.25 animations:^{
            self.contentView.transform = CGAffineTransformMakeTranslation(0, -offset);
        }];
    }
    
}

@end
