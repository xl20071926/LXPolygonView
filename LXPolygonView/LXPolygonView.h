//
//  LXPolygonView.h
//  LXPolygonView
//
//  Created by Leexin on 17/2/5.
//  Copyright © 2017年 Garden.Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXPolygonView : UIView

@property (nonatomic, assign) NSInteger sideNumber; // 需大于等于3
@property (nonatomic, strong) NSArray *valueArray;
@property (nonatomic, strong) NSArray *titleArray;

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius sideNumber:(NSInteger)sideNumber; // sideNumber需大于等于3
- (void)reloadPolygonView;

@end
