## What BlockCondition is

BlockCondition is a class that mimics some aspects of NSCondition, but uses block callbacks instead of blocking the caller. This is useful when coding using the Continuation Passing Style pattern.

Specifically, the class implements a condition that allows any number of blocks to "wait" with `waitInBackgroundWithBlock:` until the condition is set with `broadcast`. When the condition is set, all waiting blocks are executed. After the condition has been set, any further call to wait on the condition will result in the immediate execution of the passed block. A condition that has been set can be recycled for another use with `reset`.

## What BlockCondition isn't

BlockConditions are intended to synchronize among blocks executed on the same thread. Unlink NSCondition, BlockCondition is not thread-safe and not intended to be shared among threads.

Furthermore, it is illegal to set or reset a condition from within a waiting block. Doing so results in a exception thrown. These constraints guarantee that the condition is set throughout the execution of the conditional block.

## Interface

```
@interface BlockCondition : NSObject

@property (readonly) BOOL           condition;

+ (id)blockCondition;
- (void)waitInBackgroundWithBlock:(void(^)())block;
- (void)waitInBackground:(BOOL)asynchronous block:(void (^)(BOOL))block;
- (void)broadcast;
- (void)reset;

@end
```