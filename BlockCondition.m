//
//  BlockCondition.m
//
//  Copyright (c) 2014 Cyril Meurillon. All rights reserved.
//

#import "BlockCondition.h"

@interface BlockCondition ()

@property (readwrite) BOOL                  condition;
@property (nonatomic) NSInteger             entered;
@property (nonatomic) NSMutableOrderedSet   *queue;

@end



@implementation BlockCondition

// allocate and initialize a block condition

+ (id)blockCondition
{
    return [[BlockCondition alloc] init];
}

// initialize a block condition

- (id)init
{
    _condition = FALSE;
    _entered = 0;
    _queue = [NSMutableOrderedSet orderedSet];
    assert(_queue);
    return self;
}

// submit a block to be executed when the condition is set

- (void)waitInBackgroundWithBlock:(void(^)())block
{
    // we call the generic form of the wait method
    
    [self waitInBackground:TRUE block:^(BOOL success) {
        block();
    }];
}

// submit a block to be executed when the condition is set

- (void)waitInBackground:(BOOL)asynchronous block:(void (^)(BOOL))block
{
    // if the condition is set, execute the block right away and return
    
    if (self.condition) {
        
        // increment the reentry count before we invoke the block
        
        self.entered++;
        
        // invoke the block and indicate success
        
        block(TRUE);
        
        // decrement the reentry count after the block has been invoked
        
        self.entered--;
        return;
    }
    
    // the condition is not set. if the block needs to be called immediately,
    // do so and return
    
    if (!asynchronous) {
        
        // increment the reentry count before we invoke the block

        self.entered++;
        
        // invoke the block and indicate failure

        block(FALSE);
        
        // decrement the reentry count after the block has been invoked

        self.entered--;
        return;
    }
    
    // add the block to the block queue
    
    [self.queue addObject:block];
}

// set the condition

- (void)broadcast
{
    // throw an exception if this is called from within a conditional block
    
    if (self.entered > 0) {
        NSException     *exception;
        exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                            reason:@"calling broadcast on a BlockCondition from within a conditional block"
                                          userInfo:nil];
        @throw exception;
    }
    
    // set the condition
    
    self.condition = TRUE;
    
    // increment the reentry count before the invoke the conditional blocks
    
    self.entered++;
    
    // invoke all the blocks on the block queue and indicate success
    
    for(void (^block)() in self.queue) {
        block(TRUE);
    }
    
    // decrement the reentry count after the invoke the conditional blocks

    self.entered--;
    
    // remove all blocks from the block queue
    
    [self.queue removeAllObjects];
}

// reset a condition block for further use

- (void)reset
{
    // throw an exception if this is called from within a conditional block
    
    if (self.entered > 0) {
        NSException     *exception;
        exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                            reason:@"calling reset on a BlockCondition from within a conditional block"
                                          userInfo:nil];
        @throw exception;
    }
    
    // set the condition to false
    
    self.condition = FALSE;
    
    // remove any block in the block queue
    
    [self.queue removeAllObjects];
}

@end
