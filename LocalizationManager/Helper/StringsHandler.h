//
//  StringsHandler.h
//  LocalizationManager
//
//  Created by Francesca Corsini on 15/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringsHandler : NSObject

// the array with the strings from the master .strings file
@property (nonatomic, strong) NSMutableArray *masterStrings;

// the array with the strings from the secondary .strings file
@property (nonatomic, strong) NSMutableArray *secondaryStrings;

// the array with all the strings from 2 .strings file
@property (nonatomic, strong) NSMutableArray *mergedStrings;


// init
+ (instancetype)sharedInstance;

// merge .strings
- (void)mergeStrings;

// parsing .strings
- (void)parseMasterStrings:(NSString*)strings;
- (void)parseSecondaryStrings:(NSString*)strings;

@end
