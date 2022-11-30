//
//  TUIGroupCreateController.h
//  TUIContact
//
//  Created by wyl on 2022/8/22.
//

#import <UIKit/UIKit.h>
#import "TUIDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupCreateController : UIViewController
@property (nonatomic, strong) V2TIMGroupInfo *createGroupInfo;
@property (nonatomic, strong) NSArray<TUICommonContactSelectCellData *> *createContactArray;
@property (nonatomic, copy) void (^submitCallback)(BOOL isSuccess,V2TIMGroupInfo * info);
@end

NS_ASSUME_NONNULL_END
