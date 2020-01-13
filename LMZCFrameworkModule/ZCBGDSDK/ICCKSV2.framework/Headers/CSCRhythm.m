//
//  CSCBeats.m
//  CSCBluetoothAppDemo
//
//  Created by ZTELiuyw on 15/9/15.
//  Copyright (c) 2015年 刘彦玮. All rights reserved.
//

#import "CSCRhythm.h"
#import "CSCDefine.h"

@implementation CSCRhythm {
    BOOL isOver;
    BBBeatsBreakBlock blockOnBeatBreak;
    BBBeatsOverBlock blockOnBeatOver;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //beatsInterval
        _beatsInterval = KCSCRHYTHM_BEATS_DEFAULT_INTERVAL;
    }
    return  self;
}

- (void)beats {
    
    if (isOver) {
        CSCLog(@">>>beats isOver");
        return;
    }
    
    CSCLog(@">>>beats at :%@",[NSDate date]);
    if (self.beatsTimer) {
        [self.beatsTimer setFireDate: [[NSDate date]dateByAddingTimeInterval:self.beatsInterval]];
    }
    else {
       self.beatsTimer = [NSTimer timerWithTimeInterval:self.beatsInterval target:self selector:@selector(beatsBreak) userInfo:nil repeats:YES];
        [self.beatsTimer setFireDate: [[NSDate date]dateByAddingTimeInterval:self.beatsInterval]];
        [[NSRunLoop currentRunLoop] addTimer:self.beatsTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)beatsBreak {
     CSCLog(@">>>beatsBreak :%@",[NSDate date]);
    [self.beatsTimer setFireDate:[NSDate distantFuture]];
    if (blockOnBeatBreak) {
        blockOnBeatBreak(self);
    }
}

- (void)beatsOver {
    CSCLog(@">>>beatsOver :%@",[NSDate date]);
    [self.beatsTimer setFireDate:[NSDate distantFuture]];
    isOver = YES;
    if (blockOnBeatOver) {
        blockOnBeatOver(self);
    }
    
}

- (void)beatsRestart {
    CSCLog(@">>>beatsRestart :%@",[NSDate date]);
    isOver = NO;
    [self beats];
}

- (void)setBlockOnBeatsBreak:(void(^)(CSCRhythm *bry))block {
    blockOnBeatBreak = block;
}

- (void)setBlockOnBeatsOver:(void(^)(CSCRhythm *bry))block {
    blockOnBeatOver = block;
}

@end
