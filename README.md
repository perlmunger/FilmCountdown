Film Countdown Core Animation Layer
===================================

I wanted some sort of countdown mechanism for a project I was working on, so I created this Core Animation layer. Here is a screenshot of what it produces:

![Countdown Image](http://i.imgur.com/OrFzSfQ.gif)

Here is how you use the code. To add it to a view controller,

```
- (void)viewDidLoad
{
  [super viewDidLoad];

  _filmCountdownLayer = [MLFilmCountdownLayer layer];
  [_filmCountdownLayer setPosition:[[self view] center]];
  
  [[[self view] layer] addSublayer:_filmCountdownLayer];

}
```

Then, create some action and trigger the animation and provide it a completion block.

```
- (IBAction)didTapRunAnimationButton:(id)sender
{
  [_filmCountdownLayer setOpacity:1.0f];
  [_filmCountdownLayer setCount:5];
  [_filmCountdownLayer startCountdownWithCompletionBlock:^{
    [CATransaction begin];
    [CATransaction setAnimationDuration:2.0f];
    [_filmCountdownLayer setOpacity:0.0f];
    [CATransaction commit];
  }];
}
```

This code fades the whole countdown layer to a zero opacity when the animation has completed.

The code is MIT licensed. Have fun with it. Submit pull requests if you add some cool or interesting additions. Keep in mind, though, that I might ignore you. 

Thanks and have fun.


