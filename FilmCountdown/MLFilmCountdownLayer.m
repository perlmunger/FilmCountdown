// Copyright 2013 Matt Long http://www.cimgf.com/
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MLFilmCountdownLayer.h"

#define kDefaultLayerSize CGSizeMake(500.0f, 310.0f)
#define kDefaultFilmTrackSizeRatio 0.04f
#define kDefaultInsetRatio 0.08f
#define kDefaultFilmTrackInsetRatio 0.02f
#define kDefaultFontSizeRatio 0.5f
#define kRotationLayerSizeRatio 50.0f

#define kCrosshairLineWidth 5.0f

@implementation MLFilmCountdownLayer

+ (id)layer
{
  return [[[self class] alloc] init];
}

- (id)init
{
  return [self initWithFrame:CGRectMake(0.0f, 0.0f, kDefaultLayerSize.width, kDefaultLayerSize.height)];
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super init];
  if (self) {
    [self setBounds:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    [self setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self setBorderWidth:1.0f];
    [self setShouldRasterize:YES];
    [self setRasterizationScale:[[UIScreen mainScreen] scale]];
    [self buildSublayers];
  }
  return self;
}

- (id)initWithLayer:(id)layer {
	if(self = [super initWithLayer:layer]) {
		if([layer isKindOfClass:[MLFilmCountdownLayer class]]) {
			MLFilmCountdownLayer *other = (MLFilmCountdownLayer*)layer;
      [self setCount:[other count]];
			[self setCounterLayer:[other counterLayer]];
		}
	}
	return self;
}

- (void)buildSublayers
{
  // Film Tracks
  CGSize filmTrackSize = CGSizeMake(kDefaultLayerSize.width * kDefaultFilmTrackSizeRatio, kDefaultLayerSize.width * kDefaultFilmTrackSizeRatio);
  CGFloat filmTrackInsetValue = kDefaultLayerSize.width * kDefaultFilmTrackInsetRatio;
  
  CGFloat height = [self bounds].size.height;
  CGFloat by = filmTrackSize.height + filmTrackInsetValue;
  CGFloat startY = filmTrackInsetValue;
  CGFloat rightX = [self bounds].size.width - filmTrackSize.width - filmTrackInsetValue;
  
  NSInteger iterations = height / by;
  for (NSInteger index = 0; index < iterations; ++index) {
    CALayer *leftTrackLayer = [CALayer layer];
    [leftTrackLayer setBounds:CGRectMake(0.0f, 0.0f, filmTrackSize.width, filmTrackSize.height)];
    [leftTrackLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [leftTrackLayer setPosition:CGPointMake(filmTrackInsetValue, startY + by * index)];
    [leftTrackLayer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [self addSublayer:leftTrackLayer];

    CALayer *rightTrackLayer = [CALayer layer];
    [rightTrackLayer setBounds:CGRectMake(0.0f, 0.0f, filmTrackSize.width, filmTrackSize.height)];
    [rightTrackLayer setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [rightTrackLayer setPosition:CGPointMake(rightX, startY + by * index)];
    [rightTrackLayer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [self addSublayer:rightTrackLayer];
  }
  
  // Inner Rectangle
  CGRect insetRect = CGRectInset([self bounds], filmTrackSize.width + filmTrackInsetValue *2, filmTrackInsetValue);
  CAGradientLayer *innerLayer = [CAGradientLayer layer];
  [innerLayer setBounds:insetRect];
  [innerLayer setPosition:CGPointMake([self bounds].size.width/2.0f, [self bounds].size.height/2.0f)];
  [innerLayer setStartPoint:CGPointMake(0.0f, 0.0f)];
  [innerLayer setEndPoint:CGPointMake(1.0f, 1.0f)];
  [innerLayer setColors:@[(id)[[UIColor lightGrayColor] CGColor],
                          (id)[[UIColor darkGrayColor] CGColor],
                          (id)[[UIColor lightGrayColor] CGColor]]];
  [innerLayer setMasksToBounds:YES];
  [self addSublayer:innerLayer];
  
  // Rotator
  _rotationLayer = [CAShapeLayer layer];
  [_rotationLayer setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width, [self bounds].size.width)];
  [_rotationLayer setPosition:CGPointMake([self bounds].size.width/2.0f, [self bounds].size.height/2.0f)];
  [_rotationLayer setFillColor:[[UIColor clearColor] CGColor]];
  [_rotationLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
  [_rotationLayer setOpacity:0.25];
  [_rotationLayer setLineWidth:[self bounds].size.width];
  [_rotationLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0f, 0.0f, [self bounds].size.width, [self bounds].size.width)] CGPath]];
  [_rotationLayer setTransform:CATransform3DMakeRotation(-0.5 * M_PI, 0.0f, 0.0f, 1.0f)];
  [innerLayer addSublayer:_rotationLayer];
  
  // Vertical Line
  CALayer *verticalLineLayer = [CALayer layer];
  [verticalLineLayer setBounds:CGRectMake(0.0f, 0.0f, kCrosshairLineWidth, insetRect.size.height)];
  [verticalLineLayer setPosition:CGPointMake([self bounds].size.width/2.0f, [self bounds].size.height/2.0f)];
  [verticalLineLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
  [innerLayer addSublayer:verticalLineLayer];
  
  // Horizontal Line
  CALayer *horizontalLineLayer = [CALayer layer];
  [horizontalLineLayer setBounds:CGRectMake(0.0f, 0.0f, insetRect.size.width, kCrosshairLineWidth)];
  [horizontalLineLayer setPosition:CGPointMake([self bounds].size.width/2.0f, [self bounds].size.height/2.0f)];
  [horizontalLineLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
  [innerLayer addSublayer:horizontalLineLayer];
  
  // Outer Cirle
  CGRect outerCircleInsetRect = CGRectInset(CGRectMake(0.0f, 0.0f, insetRect.size.height, insetRect.size.height), 10.0f, 10.0f);
  CALayer *outerCircleLayer = [CALayer layer];
  [outerCircleLayer setBounds:outerCircleInsetRect];
  [outerCircleLayer setPosition:CGPointMake([self bounds].size.width/2.0f, [self bounds].size.height/2.0f)];
  [outerCircleLayer setCornerRadius:[outerCircleLayer bounds].size.width/2.0f];
  [outerCircleLayer setBorderWidth:kCrosshairLineWidth];
  [outerCircleLayer setBorderColor:[[UIColor whiteColor] CGColor]];
  [innerLayer addSublayer:outerCircleLayer];
  
  // Inner Cirle
  CGRect innerCircleInsetRect = CGRectInset(outerCircleLayer.bounds, 10.0f, 10.0f);
  CALayer *innerCircleLayer = [CALayer layer];
  [innerCircleLayer setBounds:innerCircleInsetRect];
  [innerCircleLayer setPosition:CGPointMake([self bounds].size.width/2.0f, [self bounds].size.height/2.0f)];
  [innerCircleLayer setCornerRadius:[innerCircleLayer bounds].size.width/2.0f];
  [innerCircleLayer setBorderWidth:kCrosshairLineWidth];
  [innerCircleLayer setBorderColor:[[UIColor whiteColor] CGColor]];
  [innerLayer addSublayer:innerCircleLayer];
  
  // Counter Layer
  _counterLayer = [CATextLayer layer];
  [_counterLayer setBounds:[innerLayer bounds]];
  [_counterLayer setPosition:CGPointMake([self bounds].size.width/2.0f, [self bounds].size.height/2.0f)];
  [_counterLayer setForegroundColor:[[UIColor blackColor] CGColor]];
  [_counterLayer setAlignmentMode:kCAAlignmentCenter];
  [_counterLayer setFontSize:kDefaultLayerSize.width * kDefaultFontSizeRatio];
  [innerLayer addSublayer:_counterLayer];
  
}

+ (BOOL)needsDisplayForKey:(NSString*)key {
  if ([key isEqualToString:@"count"]) {
    return YES;
  } else {
    return [super needsDisplayForKey:key];
  }
}

- (void)drawInContext:(CGContextRef)ctx
{
  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  [_counterLayer setString:[NSString stringWithFormat:@"%d", [self count]]];
  [CATransaction commit];
}

#pragma mark - Animations
- (void)startCountdownWithCompletionBlock:(dispatch_block_t)completionBlock
{
  CFTimeInterval mediaTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
  
  CAKeyframeAnimation *countdownAnimation = [CAKeyframeAnimation animationWithKeyPath:@"count"];
  [countdownAnimation setDelegate:self];
  NSMutableArray *values = [NSMutableArray array];
  for (NSInteger i = [self count]+1; i >= 0; --i) {
    [values addObject:@(i)];
  }
  [countdownAnimation setValue:_counterLayer forKey:@"AnimationLayer"];
  [countdownAnimation setValues:values];
  [countdownAnimation setDuration:(CFTimeInterval)[self count]];
  [countdownAnimation setValue:completionBlock forKey:@"completion"];
  [countdownAnimation setBeginTime:mediaTime];
  
  [self addAnimation:countdownAnimation forKey:@"count"];
  
  CABasicAnimation *shapeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
  [shapeAnimation setFromValue:(id)@(0.0f)];
  [shapeAnimation setToValue:(id)@(1.0f)];
  [shapeAnimation setDuration:1.0f];
  [shapeAnimation setRepeatCount:[self count]];
  [shapeAnimation setBeginTime:mediaTime];
  [_rotationLayer addAnimation:shapeAnimation forKey:@"strokeEnd"];

  [_counterLayer setString:@""];
  [self setCount:0];
  
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  if ([anim valueForKey:@"completion"]) {
    dispatch_block_t completion = [anim valueForKey:@"completion"];
    if (completion)
      completion();
  }
}

@end
