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
@property (nonatomic, strong) UIButton *fillButton;
@property (nonatomic, strong) UIButton *textButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextField *textField;
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
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.deleteButton setImage:[UIImage imageNamed:@"deletebutton"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteShape) forControlEvents:UIControlEventTouchUpInside];
    
    self.fillButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.fillButton setImage:[UIImage imageNamed:@"fillbutton"] forState:UIControlStateNormal];
    [self.fillButton addTarget:self action:@selector(switchFilled) forControlEvents:UIControlEventTouchUpInside];
    
    self.textButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.textButton setImage:[UIImage imageNamed:@"textbutton"] forState:UIControlStateNormal];
    [self.textButton addTarget:self action:@selector(addRemoveText) forControlEvents:UIControlEventTouchUpInside];
    
    self.keyboardDismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    [self.keyboardDismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    self.keyboardDismissButton.backgroundColor = [UIColor lightGrayColor];
    [self.keyboardDismissButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.keyboardDismissButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.keyboardDismissButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    
    self.textView = [[UITextView alloc] init];
    self.textView.font = [UIFont fontWithName:@"SourceSansPro-Bold" size:30];
    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.backgroundColor = [UIColor clearColor];
    [self.textView setInputAccessoryView:self.keyboardDismissButton];
    
    self.textField = [[UITextField alloc] init];
    [self.textField setBorderStyle:UITextBorderStyleRoundedRect];
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.textField setFont:[UIFont boldSystemFontOfSize:22]];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    [self.textField setTextAlignment:NSTextAlignmentCenter];
    self.textField.backgroundColor = [UIColor whiteColor];
    self.textField.layer.cornerRadius = 6.0f;
    self.textField.layer.masksToBounds = YES;
    self.textField.delegate = self;
    [self.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];

}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqual:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)keyboardShown:(NSNotification*)notification{
    CGFloat kbHeight = 0.0;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        kbHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.width;
    }
    else {
        kbHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    }
    CGFloat duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (self.textView.superview) {
        if (self.textView.center.y > kbHeight - 50) {
            
            [UIView animateWithDuration:duration animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, - 2*(self.textView.center.y - (kbHeight - 50)));
            } completion:nil];
        }
    }
    else if(self.textField.superview){
        [UIView animateWithDuration:duration animations:^{
            self.textField.center = CGPointMake(self.textField.center.x, self.bounds.size.height - kbHeight - self.textField.bounds.size.height/2);
        }];
    }

}

- (void)keyboardHide:(NSNotification*)notification{
    CGFloat duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (self.textView.superview) {
        [UIView animateWithDuration:duration animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self.textView removeFromSuperview];
        }];
    }
    else if(self.textField.superview){
        [UIView animateWithDuration:duration animations:^{
            self.textField.center = CGPointMake(self.textField.center.x, self.bounds.size.height);
        } completion:^(BOOL finished) {
            self.selectedShape.text = self.textField.text;
            [self.textField removeFromSuperview];
            self.textField.text = @"";
            [self setNeedsDisplay];
        }];
    }
    
    
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
        
        if (shape.type == YMShapeTypeLine) {
            CGContextAddPath(context, shape.path);
            CGContextSetShadow(context, CGSizeMake(1, 1), 0);
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
        }
        else if(shape.type == YMShapeTypeBlur){
            CGContextAddPath(context, shape.path);
            float dash[2]={6,5};
            CGContextSetLineDash(context,0,dash,2);
            CGContextSetLineWidth(context, 2.0);
            CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
            CGContextDrawPath(context, kCGPathStroke);
            CGContextRestoreGState(context);
        }
        else if(shape.type == YMSHapeTypeText){
            CGContextSetShadow(context, CGSizeMake(1, 1), 0);
            [fillColor set];
            [shape.text drawInRect:CGPathGetBoundingBox(shape.path) withFont:[UIFont fontWithName:@"SourceSansPro-Bold" size:30] lineBreakMode:NSLineBreakByCharWrapping];
            CGContextRestoreGState(context);
        }
        else{
            if (shape.filled) {
                switch (shape.type) {
                    case YMShapeTypeRectangle:
                    case YMShapeTypeCircular:
                    case YMShapeTypeStar:
                    case YMShapeTypeRoundedRectangle:
                    case YMShapeTypeArrow:
                        CGContextAddPath(context, shape.path);
                        CGContextSetShadow(context, CGSizeMake(1, 1), 0);
                        CGContextStrokePath(context);
                        break;
                    default:
                        break;
                }
                CGContextRestoreGState(context);
                
                
                CGContextSaveGState(context);
                CGContextConcatCTM(context, shape.transform);
                CGContextSetLineWidth(context, 0.0);
                CGContextAddPath(context, shape.path);
                CGContextDrawPath(context, kCGPathFillStroke);
                CGContextRestoreGState(context);
            }
            else{
                switch (shape.type) {
                    case YMShapeTypeRectangle:
                    case YMShapeTypeCircular:
                    case YMShapeTypeStar:
                    case YMShapeTypeRoundedRectangle:
                    case YMShapeTypeArrow:
                        CGContextAddPath(context, shape.path);
                        CGContextSetShadow(context, CGSizeMake(1, 1), 0);
                        CGContextDrawPath(context, kCGPathStroke);
                        break;
                    default:
                        break;
                }
                CGContextRestoreGState(context);

            }
            
            if ([shape.text length]) {
                CGContextSaveGState(context);
                CGContextConcatCTM(context, shape.transform);
                [shape.textColor set];
                CGRect pathrect = CGPathGetBoundingBox(shape.path);
                CGSize textSize = [shape.text sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:pathrect.size lineBreakMode:NSLineBreakByWordWrapping];
                CGRect newTextFrame = CGRectInset(pathrect, 0, (pathrect.size.height - textSize.height) / 2);
                [shape.text drawInRect:newTextFrame withFont:[UIFont boldSystemFontOfSize:18] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
                CGContextRestoreGState(context);
            }
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

- (void)switchFilled{
    if (self.selectedShape == nil) {
        return;
    }
    self.selectedShape.filled = !self.selectedShape.filled;
    [self setNeedsDisplay];
}

- (void)addRemoveText{
    if (self.selectedShape == nil) {
        return;
    }
    self.textField.text = self.selectedShape.text;
    self.textField.frame = CGRectMake(0, 0, self.bounds.size.width, 40);
    self.textField.center = CGPointMake(self.textField.center.x, self.bounds.size.height);
    [self addSubview:self.textField];
    [self.textField becomeFirstResponder];
    self.selectedShape.textColor = [YMProperty currentColor];
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
    
    CGRect shapeBox = CGPathGetPathBoundingBox(self.selectedShape.path);
    self.deleteButton.center = CGPointMake(shapeBox.origin.x, shapeBox.origin.y - 20);
    self.deleteButton.transform = self.selectedShape.transform;
    [self addSubview:self.deleteButton];
    
    if (!(self.selectedShape.type == YMSHapeTypeText ||
        self.selectedShape.type == YMShapeTypeLine)) {
        self.fillButton.center = CGPointMake(shapeBox.origin.x + 55, self.deleteButton.center.y);
        self.fillButton.transform = self.selectedShape.transform;
        [self addSubview:self.fillButton];
    }
    if (!(self.selectedShape.type == YMSHapeTypeText ||
          self.selectedShape.type == YMShapeTypeArrow)) {
        self.textButton.center = CGPointMake(shapeBox.origin.x + 2*55, self.deleteButton.center.y);
        self.textButton.transform = self.selectedShape.transform;
        [self addSubview:self.textButton];
    }
}

- (void)removeSelectionAnimation{
    [self.deleteButton removeFromSuperview];
    [self.fillButton removeFromSuperview];
    [self.textButton removeFromSuperview];
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
    self.fillButton.transform = self.selectedShape.transform;
    self.textButton.transform = self.selectedShape.transform;
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
    else if(!self.selectedShape && !self.touchToOpenDrawer){
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGFloat distance = distanceBetween(self.startPoint, point);
        CGFloat distanceFilter = [YMProperty currentShapeType] == YMShapeTypeArrow ? 80 : 40;
        if (distance < distanceFilter) {
            distance = distanceFilter;
            CGPoint  newpoint = CGPointMake(self.startPoint.x + distance, self.startPoint.y);
            double angleInRadian = atan2(point.y-self.startPoint.y,point.x-self.startPoint.x);
            newpoint = rotatePoint(newpoint, angleInRadian, self.startPoint);
            if ([YMProperty currentShapeType] != YMSHapeTypeText) {
                if (self.currentShape) {
                    [self.shapes removeLastObject];
                    self.currentShape = nil;
                }
                self.currentShape = [YMShape currentShapeFromPoint:self.startPoint toPoint:newpoint];
                [self.shapes addObject:self.currentShape];
                [self setNeedsDisplay];
            }
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
        CGFloat tHeight = [@"K" sizeWithFont:textView.font].height + 5;
        self.textViewHeight += tHeight;
        [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, self.textViewHeight)];
        self.transform = CGAffineTransformTranslate(self.transform, 0, -(tHeight+27));
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
    return TRUE;
}
@end
