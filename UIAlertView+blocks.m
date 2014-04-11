//
//  UIAlertView+blocks.m
//
//  Created by Julian Weinert on 10.04.14.
//  Copyright (c) 2013 Julian Weinert.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "UIAlertView+blocks.h"
#import <objc/runtime.h>

UIAlertViewCompletionBlock completionBlock;

@implementation UIAlertView (blocks)

BOOL selector_belongsToProtocol(SEL selector, Protocol *protocol) {
    for (int optionbits = 0; optionbits < (1 << 2); optionbits++) {
        BOOL required = optionbits & 1;
        BOOL instance = !(optionbits & (1 << 1));
        struct objc_method_description hasMethod = protocol_getMethodDescription(protocol, selector, required, instance);
		
        if (hasMethod.name || hasMethod.types) {
            return YES;
        }
    }
    
    return NO;
}

- (void)showWithCompletionBlock:(UIAlertViewCompletionBlock)completion {
	objc_setAssociatedObject(self, "completionBlock", completion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(self, "savedDelegate", [self delegate], OBJC_ASSOCIATION_ASSIGN);
	
	[self setDelegate:self];
	[self show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	UIAlertViewCompletionBlock block = objc_getAssociatedObject(self, "completionBlock");
	block(buttonIndex);
	
	id<UIAlertViewDelegate>savedDelegate = objc_getAssociatedObject(self, "savedDelegate");
	
	if ([savedDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
		[savedDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
	}
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
	if (selector_belongsToProtocol(aSelector, @protocol(UIAlertViewDelegate))) {
		if ([self respondsToSelector:aSelector]) {
			return self;
		}
		else {
			return objc_getAssociatedObject(self, "savedDelegate");
		}
	}
	
	return [super forwardingTargetForSelector:aSelector];
}

@end
