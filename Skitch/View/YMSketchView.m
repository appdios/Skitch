//
//  YMSketchView.m
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMSketchView.h"
#import "YMShape.h"

@interface YMSketchView()
@property (nonatomic) BOOL touchToOpenDrawer;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic, strong) YMShape *selectedShape;
@property (nonatomic, strong) YMShape *currentShape;
@property (nonatomic, strong) CAShapeLayer *animationLayer;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic) CGFloat textViewHeight;
@property (nonatomic) BOOL backPressed;
@property (nonatomic, strong) UIButton *keyboardDismissButton;
@end

@implementation YMSketchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (void)commonInitialization
{
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    self.shapes = [NSMutableArray array];
    self.animationLayer = [CAShapeLayer layer];
    [self.animationLayer setFillColor:[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor]];
    [self.animationLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
    [self.animationLayer setLineWidth:2.0f];
    [self.animationLayer setLineJoin:kCALineJoinRound];
    [self.animationLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],
      nil]];
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [self.deleteButton setImage:[UIImage imageNamed:@"deletebutton"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteShape) forControlEvents:UIControlEventTouchUpInside];
    
    self.keyboardDismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    [self.keyboardDismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    self.keyboardDismissButton.backgroundColor = [UIColor grayColor];
    [self.keyboardDismissButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    self.textView = [[UITextView alloc] init];
    self.textView.font = [UIFont fontWithName:@"SourceSansPro-Bold" size:30];
    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.backgroundColor = [UIColor clearColor];
    [self.textView setInputAccessoryView:self.keyboardDismissButton];

}

- (void)dismissKeyboard{
    if (self.textView.superview) {
        [self.textView resignFirstResponder];
        [self.textView removeFromSuperview];
        return;
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);

    [self.shapes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        YMShape *shape = (YMShape*)obj;
        UIColor *fillColor = shape.color;
        CGContextSetLineWidth(context, 4.0);
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
        
        
        CGContextSaveGState(context);
        float normal[1]={1};
        CGContextSetLineDash(context,0,normal,0);
        CGContextConcatCTM(context, shape.transform);
        
        
        switch (shape.type) {
            case YMShapeTypeRectangle:
            case YMShapeTypeCircular:
            case YMShapeTypeStar:
            case YMShapeTypeRoundedRectangle:
                CGContextAddPath(context, shape.path);
                CGContextSetShadow(context, CGSizeMake(1, 1), 0);
                CGContextDrawPath(context, kCGPathStroke);
                break;
            case YMShapeTypeArrow:
//            case YMShapeTypeStar:
                CGContextAddPath(context, shape.path);
                CGContextSetShadow(context, CGSizeMake(1, 1), 0);
                CGContextStrokePath(context);
                break;
            case YMShapeTypeLine:
                CGContextAddPath(context, shape.path);
                CGContextSetShadow(context, CGSizeMake(1, 1), 0);
                CGContextStrokePath(context);
                break;
            case YMShapeTypeBlur:
            {
                CGContextAddPath(context, shape.path);
                float dash[2]={6,5};
                CGContextSetLineDash(context,0,dash,2);
                CGContextSetLineWidth(context, 2.0);
                CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
                CGContextDrawPath(context, kCGPathStroke);
            }
                break;
            case YMSHapeTypeText:
                CGContextSetShadow(context, CGSizeMake(1, 1), 0);
                [fillColor set];
                [shape.text drawInRect:CGPathGetBoundingBox(shape.path) withFont:[UIFont fontWithName:@"SourceSansPro-Bold" size:30] lineBreakMode:NSLineBreakByCharWrapping];
                break;
            default:
                break;
        }
        CGContextRestoreGState(context);
        
        
        if ((shape.type == YMShapeTypeArrow)
//            ||
//            (shape.type == YMShapeTypeStar)
            ) {
            CGContextSaveGState(context);
            CGContextConcatCTM(context, shape.transform);
            CGContextSetLineWidth(context, 0.0);
            CGContextAddPath(context, shape.path);
            CGContextDrawPath(context, kCGPathFillStroke);
            CGContextRestoreGState(context);
        }
    }];

}

- (void)deleteShape{
    if (self.selectedShape == nil) {
        return;
    }
    [self.shapes removeObject:self.selectedShape];
    [self removeSelectionAnimation];
    [self setNeedsDisplay];
}

- (void)addSelectionAnimation{

    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    [self.animationLayer setPath:self.selectedShape.path];
    self.animationLayer.transform = CATransform3DMakeAffineTransform(self.selectedShape.transform);    [CATransaction commit];
    
    
    [self.layer addSublayer:self.animationLayer];
    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation
                     animationWithKeyPath:@"lineDashPhase"];
    
    [dashAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
    [dashAnimation setToValue:[NSNumber numberWithFloat:15.0f]];
    [dashAnimation setDuration:0.75f];
    [dashAnimation setRepeatCount:10000];
    
    [self.animationLayer addAnimation:dashAnimation forKey:@"linePhase"];
    
    self.deleteButton.center = CGPathGetPathBoundingBox(self.selectedShape.path).origin;
    self.deleteButton.transform = self.selectedShape.transform;
    [self addSubview:self.deleteButton];
}

- (void)removeSelectionAnimation{
    [self.deleteButton removeFromSuperview];
    [self.animationLayer removeAllAnimations];
    [self.animationLayer removeFromSuperlayer];
}

- (void)translateFrom:(CGPoint)ppoint to:(CGPoint)point{
    self.selectedShape.transform = CGAffineTransformTranslate(self.selectedShape.transform, point.x - ppoint.x, point.y - ppoint.y);
    
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    self.animationLayer.transform = CATransform3DMakeAffineTransform(self.selectedShape.transform);
    [CATransaction commit];
    
    self.deleteButton.transform = self.selectedShape.transform;
    [self setNeedsDisplay];
}

- (YMShape*)shapeAtPoint:(CGPoint)point
{
    __block YMShape *selectedShape = nil;
    [self.shapes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        YMShape *shape = (YMShape*)obj;
        CGPoint tPoint = CGPointApplyAffineTransform(point, CGAffineTransformInvert(shape.transform));

        if ([shape isPointOnStroke:tPoint]) {
            selectedShape = shape;
            *stop = YES;
        }
//        if (CGPathContainsPoint(shape.path, nil, tPoint, YES)) {
//            selectedShape = shape;
//            *stop = YES;
//        }
    }];
    return selectedShape;
}

-(void) showTextViewAtPoint:(CGPoint)point
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kHideMenuNotification" object:nil];
    self.textView.text = @"";
    
    self.textViewHeight = 48;
    self.textView.layer.borderWidth = 1.0;
    self.textView.frame = CGRectMake(point.x, point.y, 20, self.textViewHeight);
    self.textView.delegate = self;
    self.textView.textColor = [YMProperty currentColor];
    [self addSubview:self.textView];
    [self.textView becomeFirstResponder];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, - (point.y-20));
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.textView.superview) {
        [self.textView resignFirstResponder];
        [self.textView removeFromSuperview];
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    self.startPoint = point;

    YMShape *selectedShape = [self shapeAtPoint:point];
    if (selectedShape) {
        self.selectedShape = selectedShape;
        [self addSelectionAnimation];
    }
    else{
        [self removeSelectionAnimation];
        self.selectedShape = nil;
        if (point.x < 5) {
            self.touchToOpenDrawer = YES;
        }
        else{
            self.touchToOpenDrawer = NO;
            if ([YMProperty currentShapeType] == YMSHapeTypeText) {
                [self showTextViewAtPoint:point];
            }
        }
    }

    [self.sketchDelegate touchStart];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGPoint ppoint = [touch previousLocationInView:self];

    if (self.selectedShape) {
        [self translateFrom:ppoint to:point];
    }
    else{
        if (self.touchToOpenDrawer) {
            //Show drawer
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kShowMenuNotification" object:nil];
        }
        else{
            if (self.currentShape) {
                [self.shapes removeLastObject];
                self.currentShape = nil;
            }
            
            if ([YMProperty currentShapeType] != YMSHapeTypeText) {
                self.currentShape = [YMShape currentShapeFromPoint:self.startPoint toPoint:point];
                [self.shapes addObject:self.currentShape];
                [self setNeedsDisplay];
            }
            
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([YMProperty currentShapeType] == YMShapeTypeBlur) {
        YMShape *shape = [self.shapes lastObject];
        CGRect rect = CGPathGetBoundingBox(shape.path);
        [self.sketchDelegate blurInRect:rect];
        [self.shapes removeLastObject];
        [self setNeedsDisplay];
    }
    else{
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        if (distanceBetween(self.startPoint, point)<30) {
            // TODO
        }
        
    }
    self.currentShape = nil;
    [self.sketchDelegate touchEnd];
}

- (void)readyForScreenshot{
    [self removeSelectionAnimation];
}

#pragma mark - UITextViewDelegate


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text length]==0) {
        self.backPressed = TRUE;
    }
    else
    {
        self.backPressed = FALSE;
    }
    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:[text characterAtIndex:text.length-1]])
    {
        self.textViewHeight += [@"K" sizeWithFont:textView.font].height;
        [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, self.textViewHeight)];
    }
    else{
        CGRect screenBounds = self.bounds;
        CGSize textSize = [[textView.text stringByAppendingString:text] sizeWithFont:textView.font constrainedToSize:CGSizeMake(screenBounds.size.width - textView.frame.origin.x - 20, 500) lineBreakMode:NSLineBreakByWordWrapping];
        [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textSize.width + 20, textView.contentSize.height)];
        
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (self.backPressed) {
        CGRect frame = textView.frame;
        frame.size.height = textView.contentSize.height;
        textView.frame = frame;
    }
    
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView.text length]) {
        YMShape *shape = [YMShape currentShapeFromPoint:CGPointMake(CGRectGetMinX(textView.frame) + 5, CGRectGetMinY(textView.frame) + 8) toPoint:CGPointMake(CGRectGetMaxX(textView.frame) - 5, CGRectGetMaxY(textView.frame) - 8)];
        shape.text = textView.text;
        
        [self.shapes addObject:shape];
        [self setNeedsDisplay];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
    return TRUE;
}
@end
