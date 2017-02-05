//
//  LXPolygonView.m
//  pathDome
//
//  Created by Leexin on 16/8/12.
//  Copyright © 2016年 garden. All rights reserved.
//

#import "LXPolygonView.h"
#import "LXValuePopView.h"
#import "NSArray+Category.h"

#define kCosValue(Angle) cos(M_PI / 180 * (Angle))
#define kSinValue(Angle) sin(M_PI / 180 * (Angle))

static const CGFloat kLineWidth = 1.f; // 线宽
static const NSInteger kLayerCount = 4; // 内部多边形数量
static const CGFloat kTitleDistance = 20.f; // 标题距离多边形的距离
static const CGFloat kTitleLabelSize = 25.f; // 标题Label的尺寸
static const CGFloat kResponseSize = 5.f; // 点击响应范围半径
static const NSInteger kPopViewTag = 666;
static const NSInteger kTItleLabelTag = 888;

@interface LXPolygonView () <LXValuePopViewDelegate>

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, assign) CGFloat innerAngle; // 内角大小

@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, strong) NSMutableArray *valuePointArray;
@property (nonatomic, strong) NSMutableArray *titleLabelArray;

@property (nonatomic,copy)void (^sleepBlock)();

@end

@implementation LXPolygonView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius sideNumber:(NSInteger)sideNumber {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.radius = radius;
        self.sideNumber = sideNumber;
        self.innerAngle = 360.f / sideNumber;
        self.centerPoint = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        
        self.pointArray = [NSMutableArray arrayWithCapacity:sideNumber];
        self.valuePointArray = [NSMutableArray arrayWithCapacity:sideNumber];
        self.titleLabelArray = [NSMutableArray arrayWithCapacity:sideNumber];
    }
    return self;
}

- (void)getTitleLabelArray {
    
    NSMutableArray *labelCenterPointArray = [NSMutableArray arrayWithCapacity:self.sideNumber];
    [self resetPointsWithRadius:self.radius + kTitleDistance storePointArray:labelCenterPointArray];
    for (id subView in self.subviews) {
        [subView removeFromSuperview];
    }
    for (int i = 0; i < self.sideNumber; i ++) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kTitleLabelSize, kTitleLabelSize)];
        titleLabel.center = [[labelCenterPointArray safeObjectAtIndex:i] CGPointValue];
        titleLabel.text = [self.titleArray safeObjectAtIndex:i] ?:@"空";
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.font = [UIFont systemFontOfSize:8.f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.layer.cornerRadius = kTitleLabelSize / 2;
        titleLabel.layer.borderColor = [UIColor grayColor].CGColor;
        titleLabel.layer.borderWidth = 1.f;
        titleLabel.layer.masksToBounds = YES;
        titleLabel.tag = i + kTItleLabelTag;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTitleLableClick:)];
        [titleLabel addGestureRecognizer:tap];
        titleLabel.userInteractionEnabled = YES;
        [self addSubview:titleLabel];
    }
}

- (void)resetPointsWithRadius:(CGFloat)radius storePointArray:(NSMutableArray *)array {
    
    NSMutableArray *scaleArray = [NSMutableArray array];
    for (int i = 0; i < self.sideNumber; i++) {
        [scaleArray addObject:@1];
    }
    [self resetPointsWithRadius:radius scale:scaleArray storePointArray:array];
}

- (void)resetPointsWithRadius:(CGFloat)radius scale:(NSArray *)scaleArray storePointArray:(NSMutableArray *)array {
    
    [array removeAllObjects];
    for (int i = 0; i < self.sideNumber; i++) {
        
        CGFloat currentScale = [[scaleArray safeObjectAtIndex:i] floatValue];
        CGFloat currentRadius = currentScale * radius;
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(self.centerPoint.x - (kCosValue(90 - self.innerAngle * i) * currentRadius),
                                                               self.centerPoint.y - (kSinValue(90 - self.innerAngle * i) * currentRadius))]];
    }
}

- (void)reloadPolygonView {
    
    self.innerAngle = 360.f / self.sideNumber;
    [self setNeedsDisplay];
}

#pragma mark - Draw Method

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self getTitleLabelArray];
    [self drawValueLineWithContext:context];
    [self drawPolygonWithContext:context];
}

- (void)drawPolygonWithContext:(CGContextRef)context { // 画多边形
    
    for (int i = 0 ;i < kLayerCount; i++) {
        CGFloat tempRadius = self.radius - (i * self.radius / kLayerCount);
        [self resetPointsWithRadius:tempRadius storePointArray:self.pointArray];
        CGContextMoveToPoint(context,
                             [[self.pointArray safeObjectAtIndex:0] CGPointValue].x,
                             [[self.pointArray safeObjectAtIndex:0] CGPointValue].y);
        [self drawLineToPoints:self.pointArray context:context isFromCenterPoint:NO];
        CGContextClosePath(context);
    }
    
    [self drawInsideCutLineWithContext:context];
    
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(context, kLineWidth);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawValueLineWithContext:(CGContextRef)context { // 画值区域
    
    CGContextSaveGState(context);
    
    if (self.valueArray == nil || self.valueArray.count == 0) {
        return;
    }
    [self resetPointsWithRadius:self.radius scale:self.valueArray storePointArray:self.valuePointArray];
    CGContextMoveToPoint(context,
                         [[self.valuePointArray safeObjectAtIndex:0] CGPointValue].x,
                         [[self.valuePointArray safeObjectAtIndex:0] CGPointValue].y);
    [self drawLineToPoints:self.valuePointArray context:context isFromCenterPoint:NO];
    CGContextClosePath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor purpleColor].CGColor);
    CGContextSetLineWidth(context, kLineWidth);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextRestoreGState(context);
}

- (void)drawInsideCutLineWithContext:(CGContextRef)context { // 画内部分割线
    
    [self resetPointsWithRadius:self.radius storePointArray:self.pointArray];
    [self drawLineToPoints:self.pointArray context:context isFromCenterPoint:YES];
}

- (void)drawLineToPoints:(NSArray *)pointArray context:(CGContextRef)context isFromCenterPoint:(BOOL)isFromCenterPoint { // 连线至多个点
    
    for (id pointObj in pointArray) {
        CGPoint point = [pointObj CGPointValue];
        if (isFromCenterPoint) {
            [self drawLineFromCenterToPoint:point context:context];
        } else {
            CGContextAddLineToPoint(context, point.x, point.y);
        }
    }
}

- (void)drawLineFromCenterToPoint:(CGPoint)point context:(CGContextRef)context { // 从中心点连线至指定点
    
    CGContextMoveToPoint(context, self.centerPoint.x, self.centerPoint.y);
    CGContextAddLineToPoint(context, point.x, point.y);
}

#pragma mark - Touch Delegate

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    [self showValueWithTouchPoint:touchPoint];
}

- (NSInteger)getTouchPositionWithTouchPoint:(CGPoint)touchPoint { // 获取点击区域
    
    for (int i = 0; i < self.sideNumber; i++) {
        CGPoint valuePoint = [[self.valuePointArray safeObjectAtIndex:i] CGPointValue];
        BOOL canResponse = CGRectContainsPoint(CGRectMake(valuePoint.x - kResponseSize, valuePoint.y - kResponseSize, 2 * kResponseSize, 2 * kResponseSize), touchPoint);
        if (canResponse) {
            return i;
        }
    }
    return -1;
}

#pragma mark - Show ValuePopView

- (void)showValueWithTouchPoint:(CGPoint)touchPoint {
    
    NSInteger position = [self getTouchPositionWithTouchPoint:touchPoint];
    if (position == -1) {
        return;
    }
    [self showValuePopViewWithTouchPosition:position];
}

- (void)showValuePopViewWithTouchPosition:(NSInteger)touchPosition {
    
    CGPoint valuePoint = [[self.valuePointArray safeObjectAtIndex:touchPosition] CGPointValue];
    NSString *title = [NSString stringWithFormat:@"%@",[self.valueArray safeObjectAtIndex:touchPosition] ?: @"0"];
    LXValuePopView *popView = [self viewWithTag:touchPosition + kPopViewTag];
    if (popView) {
        return;
    }
    popView = [[LXValuePopView alloc] initWithStarePoint:valuePoint];
    popView.tag = touchPosition + kPopViewTag;
    [popView showInView:self titleString:title];
}

#pragma mark - Event Response

- (void)onTitleLableClick:(UITapGestureRecognizer *)sender {
    
    NSInteger index = sender.view.tag - kTItleLabelTag;
    if (index > (self.sideNumber - 1) || index < 0) {
        return;
    }
    [self showValuePopViewWithTouchPosition:index];
}

@end
