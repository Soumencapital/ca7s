//
//  CircularView.m
//  CoreGrapics Demo
//
//  Created by 200OK-IOS3 on 08/06/17.
//  Copyright © 2017 200OK-IOS3. All rights reserved.
//

#import "CircularView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

@implementation CircularView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _maximumValue = 10.0f;
        _minimumValue = 0.0f;
        _currentValue = 0.0f;
        _arcWidth = 5;
        _lineColor = [UIColor blackColor];
        _filledLineColor = [UIColor lightGrayColor];
        _handleColor = [UIColor lightGrayColor];
        [self setFrame:frame];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self=[super initWithCoder:aDecoder]){
        _maximumValue = 10.0f;
        _minimumValue = 0.0f;
        _currentValue = 0.0f;
        _arcWidth = 5;
        _lineColor = [UIColor blackColor];
        _filledLineColor = [UIColor lightGrayColor];
        _handleColor = [UIColor lightGrayColor];
    }
    
    return self;
}

-(void)drawRect:(CGRect)rect {
    
    float width = MIN(self.frame.size.width/2.0, self.frame.size.height/2.0);
    CGFloat startAngle1 =  0;
    CGFloat endAngle1 = 2*M_PI;
    float arcWidth = 15;//self.arcWidth ? self.arcWidth : 5;
    CGPoint center1 = CGPointMake(width, width);
    UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:center1 radius:width - arcWidth startAngle:startAngle1 endAngle:endAngle1 clockwise:true];
    CGFloat dashes[] = {3, 2};
    [path1 setLineDash:dashes count:2 phase:0];
    path1.lineWidth = arcWidth - 13;
    [_lineColor setStroke];
    [path1 stroke];
    
    CGFloat startAngle =  3.0/2.0 * M_PI;
    CGFloat endAngle = 3*M_PI/2-ToRad(angle);
    CGPoint center = CGPointMake(width, width);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:width - arcWidth startAngle:startAngle endAngle:endAngle clockwise:true];
    path.lineCapStyle = kCGLineCapRound;
    path.lineWidth = arcWidth;
    [_filledLineColor setStroke];
    [path stroke];
}

-(void) drawHandle:(CGContextRef)ctx{
    CGContextSaveGState(ctx);
    CGPoint handleCenter =  [self pointFromAngle: angle];
    [_handleColor set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x - _arcWidth/2.0, handleCenter.y - _arcWidth/2.0, _arcWidth * 2 , _arcWidth * 2));
    CGContextRestoreGState(ctx);
}

-(void)drawText:(CGContextRef)ctx {
    CGContextSaveGState(ctx);
    CGPoint textCenter =  [self pointFromAngle: angle];
    NSString *text = [NSString stringWithFormat:@"%d",(int)_currentValue];
    CGSize textSize = [self getTextSize:text];
    UIFont *font = [UIFont systemFontOfSize:0.8 * _arcWidth];
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [text drawInRect:CGRectMake(textCenter.x-(textSize.width/2.0)+_arcWidth/2.0, textCenter.y-(textSize.height/2.0)+_arcWidth/2.0, textSize.width, textSize.height) withAttributes:attrsDictionary];
    CGContextRestoreGState(ctx);
}

-(CGSize) getTextSize:(NSString *)text {
    UIFont *font = [UIFont systemFontOfSize:0.8 * _arcWidth];
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    return [text sizeWithAttributes:attrsDictionary];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    angle = [self angleFromValue];
}

- (void)setCurrentValue:(float)currentValue {
    _currentValue=currentValue;
    
    if(_currentValue>=_maximumValue) {
        _currentValue= _currentValue - _maximumValue;
    } else if(_currentValue<_minimumValue) {
        _currentValue=_minimumValue - _currentValue;
        _currentValue= _maximumValue - _currentValue;
    }
    
    angle = [self angleFromValue];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}


- (CGFloat)radius {
    return self.frame.size.height/2 - _arcWidth;
}

- (float)angleFromValue {
    angle = 360 - (360.0f*_currentValue/_maximumValue);
    
    if(angle==360) angle=0;
    
    return angle;
}

-(float)valueFromAngle {
    if (angle >= 0 && angle <= 270) {
        _currentValue = _maximumValue - (angle * _maximumValue)/360;
    } else {
        _currentValue = -(angle * _maximumValue)/360;
    }
    if (_currentValue == _maximumValue) {
        _currentValue = 0;
    }
    return _currentValue;
}

-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Define the Circle center
    float width = MIN(self.frame.size.width/2.0, self.frame.size.height/2.0);
    CGPoint centerPoint = CGPointMake(width - _arcWidth/2.0, width - _arcWidth/2.0);
    
    //Define The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + self.radius * sin(ToRad(-angleInt-90))) ;
    result.x = round(centerPoint.x + self.radius * cos(ToRad(-angleInt-90)));
    
    return result;
}


static inline float GetAngle(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    NSArray *arrTouches = [touches allObjects];
    UITouch *touch = (UITouch *)arrTouches[0];
    CGPoint lastPoint = [touch locationInView:self];
    [self moveHandle:lastPoint];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    NSArray *arrTouches = [touches allObjects];
    UITouch *touch = (UITouch *)arrTouches[0];
    CGPoint lastPoint = [touch locationInView:self];
    [self moveHandle:lastPoint];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    NSArray *arrTouches = [touches allObjects];
    UITouch *touch = (UITouch *)arrTouches[0];
    CGPoint lastPoint = [touch locationInView:self];
    [self moveHandle:lastPoint];
}

-(void)moveHandle:(CGPoint)point {
    CGPoint centerPoint;
    centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    int currentAngle = floor(GetAngle(centerPoint, point, NO));
    angle = 360 - 90 - currentAngle;
    [self valueFromAngle];
    [self setNeedsDisplay];
}

@end
