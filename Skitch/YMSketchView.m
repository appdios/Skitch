//
//  YMSketchView.m
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMSketchView.h"
#import "YMShape.h"
#import "YMProperty.h"

@interface YMSketchView()

@property (nonatomic) CGPoint startPoint;
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
    self.shapes = [NSMutableArray array];
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

        CGContextAddPath(context, shape.path);
        CGContextSetShadow(context, CGSizeMake(1, 1), 0);
        
        switch (shape.type) {
            case YMShapeTypeRectangle:
            case YMShapeTypeCircular:
            case YMShapeTypeRoundedRectangle:
                CGContextDrawPath(context, kCGPathStroke);
                break;
            case YMShapeTypeArrow:
                CGContextStrokePath(context);
                break;
            case YMSHapeTypeText:
                [fillColor set];
                [shape.text drawInRect:CGPathGetBoundingBox(shape.path) withFont:[UIFont fontWithName:@"Strenuous3D" size:40]];
                break;
            default:
                break;
        }
        CGContextRestoreGState(context);
        
        if (shape.type == YMShapeTypeArrow) {
            CGContextSetLineWidth(context, 0.0);
            CGContextAddPath(context, shape.path);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    self.startPoint = point;

    YMShape *shape = [YMShape currentShapeFromPoint:self.startPoint toPoint:point];
    [self.shapes addObject:shape];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self.shapes removeLastObject];
    YMShape *shape = [YMShape currentShapeFromPoint:self.startPoint toPoint:point];
    [self.shapes addObject:shape];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

@end
