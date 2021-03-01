//
//  CircularView.h
//  CoreGrapics Demo
//
//  Created by 200OK-IOS3 on 08/06/17.
//  Copyright © 2017 200OK-IOS3. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface CircularView : UIView
{
    int angle;
}

@property(nonatomic) IBInspectable UIColor *lineColor;
@property(nonatomic) IBInspectable UIColor *filledLineColor;
@property(nonatomic) IBInspectable UIColor *handleColor;
@property(nonatomic) IBInspectable int arcWidth;
@property (nonatomic) IBInspectable float minimumValue;
@property (nonatomic) IBInspectable float maximumValue;
@property (nonatomic) IBInspectable float currentValue;
@end
