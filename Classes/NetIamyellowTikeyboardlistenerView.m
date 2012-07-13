//
//   Copyright 2012 jordi domenech <jordi@iamyellow.net>
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import "NetIamyellowTikeyboardlistenerView.h"

@implementation NetIamyellowTikeyboardlistenerView

#pragma mark Cleanup 

-(void)dealloc
{
    if (ourProxy) {
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:UIKeyboardWillShowNotification 
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:UIKeyboardWillHideNotification 
                                                      object:nil];
    }
    
    [super dealloc];
}

#pragma mark View init

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    if (!ourProxy) {
        ourProxy = (NetIamyellowTikeyboardlistenerViewProxy*)[self proxy];
        
        // must fill entire container height
        CGRect frame = self.frame;
        frame.origin.y = 0.0f; frame.size.height = self.superview.frame.size.height;
        [TiUtils setView:self positionRect:frame];
        [ourProxy setTop:NUMINT(0)];
        [ourProxy setHeight:kTiBehaviorFill];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:) 
                                                     name:UIKeyboardWillShowNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:) 
                                                     name:UIKeyboardWillHideNotification 
                                                   object:nil];	
    }
}

#pragma Keyboard listener

-(void)keyboardWillShow:(NSNotification*)note
{
    NSDictionary* userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrameBegin = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardFrameEnd = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL portrait = orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown;
    float keyboardHeight = portrait ? keyboardFrameEnd.size.height : keyboardFrameEnd.size.width;
    
    int way;
    // APPEARS FROM BOTTOM TO TOP
    if (portrait && keyboardFrameBegin.origin.x == keyboardFrameEnd.origin.x) { 
        way = 0;
    }
    else if (!portrait && keyboardFrameBegin.origin.y == keyboardFrameEnd.origin.y) { 
        way = 1;
    }        
    // APPEARS FROM RIGHT TO LEFT (NAVIGATION CONTROLLER, OPENING WINDOW)
    else if (portrait && keyboardFrameBegin.origin.y == keyboardFrameEnd.origin.y) { 
        way = 2;
    }
    else if (!portrait && keyboardFrameBegin.origin.x == keyboardFrameEnd.origin.x) { 
        way = 3;
    }
    
    if (way < 2) {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|curve animations:^{
            CGRect frame = self.frame;
            frame.size.height = self.superview.frame.size.height - keyboardHeight;
            
            [TiUtils setView:self positionRect:frame];
            [ourProxy setHeight:NUMFLOAT(frame.size.height)];
        } completion:^(BOOL finished) {
            if ([ourProxy _hasListeners:@"keyboard:show"]) {
                CGRect frame = self.frame;
                NSMutableDictionary* event = [NSMutableDictionary dictionary];
                [event setObject:NUMFLOAT(keyboardHeight) forKey:@"keyboardHeight"];
                [event setObject:NUMFLOAT(frame.size.height) forKey:@"height"];
                [ourProxy fireEvent:@"keyboard:show" withObject:event];
            }
        }];
    }
    else {
        CGRect frame = self.frame;
        frame.size.height = self.superview.frame.size.height - keyboardHeight;
        
        [TiUtils setView:self positionRect:frame];
        [ourProxy setHeight:NUMFLOAT(frame.size.height)];
        
        if ([ourProxy _hasListeners:@"keyboard:show"]) {
            NSMutableDictionary* event = [NSMutableDictionary dictionary];
            [event setObject:NUMFLOAT(keyboardHeight) forKey:@"keyboardHeight"];
            [event setObject:NUMFLOAT(frame.size.height) forKey:@"height"];
            [ourProxy fireEvent:@"keyboard:show" withObject:event];
        }
    }
}

-(void)keyboardWillHide:(NSNotification *)note
{
    NSDictionary* userInfo = note.userInfo;
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGRect keyboardFrameBegin = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardFrameEnd = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL portrait = orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown;    
    float keyboardHeight = portrait ? keyboardFrameEnd.size.height : keyboardFrameEnd.size.width;
    
    int way;
    // APPEARS FROM BOTTOM TO TOP
    if (portrait && keyboardFrameBegin.origin.x == keyboardFrameEnd.origin.x) { 
        way = 0;
    }
    else if (!portrait && keyboardFrameBegin.origin.y == keyboardFrameEnd.origin.y) { 
        way = 1;
    }        
    // APPEARS FROM RIGHT TO RIGHT (NAVIGATION CONTROLLER, OPENING WINDOW)
    else if (portrait && keyboardFrameBegin.origin.y == keyboardFrameEnd.origin.y) { 
        way = 2;
    }
    else if (!portrait && keyboardFrameBegin.origin.x == keyboardFrameEnd.origin.x) { 
        way = 3;
    }
    
    if (way < 2) {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|curve animations:^{
            CGRect frame = self.frame;
            frame.size.height = self.superview.frame.size.height;
            
            [TiUtils setView:self positionRect:frame];
            [ourProxy setHeight:kTiBehaviorFill];
        } completion:^(BOOL finished){
            CGRect frame = self.frame;
            if ([ourProxy _hasListeners:@"keyboard:hide"]) {
                NSMutableDictionary* event = [NSMutableDictionary dictionary];
                [event setObject:NUMFLOAT(keyboardHeight) forKey:@"keyboardHeight"];
                [event setObject:NUMFLOAT(frame.size.height) forKey:@"height"];
                [ourProxy fireEvent:@"keyboard:hide" withObject:event];
            }
        }];
    }
    else {
        CGRect frame = self.frame;
        frame.size.height = self.superview.frame.size.height;
        
        [TiUtils setView:self positionRect:frame];
        [ourProxy setHeight:kTiBehaviorFill];
        
        if ([ourProxy _hasListeners:@"keyboard:hide"]) {
            NSMutableDictionary* event = [NSMutableDictionary dictionary];
            [event setObject:NUMFLOAT(keyboardHeight) forKey:@"keyboardHeight"];
            [event setObject:NUMFLOAT(frame.size.height) forKey:@"height"];
            [ourProxy fireEvent:@"keyboard:hide" withObject:event];
        }
    }
}

@end
