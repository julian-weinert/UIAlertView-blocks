UIAlertView-blocks
==================

***Category on UIAlertView that implements block support***

This category adds block support for `UIAlertView` which you can use along with the `UIAlertViewDelegate` protocol.

##Example usage
``` objective-c
- (void)showAlert {
	[[[UIAlertView alloc] initWithTitle:@"MyAlert" message:@"This is a great alert" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] showWithCompletionBlock:^(NSInteger buttonIndex) {
		NSLog(@"Alert did click button at index %i", buttonIndex);
	}];
}
```
