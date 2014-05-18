//
//  BlockCondition.h
//
//  Copyright (c) 2014 Cyril Meurillon. All rights reserved.
//

#import <Foundation/Foundation.h>

// BlockCondition is a class that mimics some aspects of NSCondition, but uses block callbacks instead
// of blocking the caller. This is useful when coding using the Continuation Passing Style pattern.
//
// Specifically, the class implements a condition that allows any number of blocks to "wait" until
// the condition is set. When the condition is set, all waiting blocks are executed. After the condition
// has been set, any further call to wait on the condition will result in the immediate execution
// of the passed block. A condition that has been set can be reset for another use.
//
// BlockConditions are intended to synchronize among blocks executed on the same thread. They are not
// thread-safe and not intended to be shared among threads. Furthermore, it is illegal to set or
// reset a condition from within a waiting block. Doing so results in a exception thrown.
// These constraints guarantee that the condition is set throughout the execution of the conditional
// block.


@interface BlockCondition : NSObject

// the condition property returns the state of the condition (read-only)

@property (readonly) BOOL           condition;

// +blockCondition returns a newly allocated condition ready for use. The condition is initially set to false.

+ (id)blockCondition;

// -waitInBackgroundWithBlock: invokes the passed block when the condition is set. The block is invoked right away
// if the condition is already set.

- (void)waitInBackgroundWithBlock:(void(^)())block;

// -waitInBackground:block: is similar to -waitInBackgroundWithBlock:, except that it takes an additional flag
// controlling whether the block invokation may be asynchronous. When that flag is not set, the block is invoked right
// away regardless of the state of the condition. The block takes a parameter that indicates whether the condition
// is set.

- (void)waitInBackground:(BOOL)asynchronous block:(void (^)(BOOL))block;

// -broadcast sets the condition. It cannot be called from within a waiting block.

- (void)broadcast;

// -reset resets the condition to false for further use. It cannot be called from within a waiting block.

- (void)reset;

@end
