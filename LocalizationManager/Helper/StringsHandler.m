//
//  StringsHandler.m
//  LocalizationManager
//
//  Created by Francesca Corsini on 15/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "StringsHandler.h"

@implementation StringsHandler

#pragma mark - Init

static StringsHandler *istance;

+ (instancetype)sharedInstance
{
    @synchronized(self)
    {
        if(istance == nil)
        {
            istance = [[StringsHandler alloc] init];
            return istance;
        }
    }
    return istance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.masterStrings = @[].mutableCopy;
        self.secondaryStrings = @[].mutableCopy;
    }
    return self;
}

#pragma mark - Parsing .strings

- (void)parseMasterStrings:(NSString*)strings
{
    
}

- (void)parseSecondaryStrings:(NSString*)strings
{
    
}

- (NSArray*)parseStrings:(NSString*)strings
{
    NSArray *arrayStrings;
    
    
    return arrayStrings;
}

@end
