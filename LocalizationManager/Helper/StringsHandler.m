//
//  StringsHandler.m
//  LocalizationManager
//
//  Created by Francesca Corsini on 15/05/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "StringsHandler.h"
#import <Cocoa/Cocoa.h>

@implementation StringsHandler

#pragma mark - Init

static StringsHandler *istance;

+ (instancetype)sharedInstance
{
    @synchronized(self)
    {
        if (istance == nil)
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
        self.mergedStrings = @[].mutableCopy;
        self.diffStrings = @[].mutableCopy;
    }
    return self;
}

#pragma mark - Diff .strings

- (void)diffStringsWithSuccess:(SuccessBlock)success failed:(FailedBlock)failed
{
    successBlock = success;
    failedBlock = failed;
    
    if ([self.masterStrings count] == 0 || [self.secondaryStrings count] == 0)
    {
        if (failedBlock)
            failedBlock();
        return;
    }

    // init diffStrings
    [self.diffStrings removeAllObjects];
    
    // add missing fields of secondaryStrings to diffStrings
    [self.masterStrings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary*)obj;
        BOOL contains = [self array:self.secondaryStrings containsField:[[dict allKeys] firstObject]];
        // add dict with value @""
        if (!contains)
        {
            [self.diffStrings addObject:@{[[dict allKeys] firstObject] : @""}];
        }
    }];
    
    // sort by alphabetic order
    self.diffStrings = [self.diffStrings sortedArrayUsingComparator: ^(id id_1, id id_2) {
        NSDictionary *d1 = (NSDictionary*) id_1;
        NSDictionary *d2 = (NSDictionary*) id_2;
        NSString *s1 = [[d1 allKeys] firstObject];
        NSString *s2 = [[d2 allKeys] firstObject];
        return [s1 compare: s2];
    }].mutableCopy;
    
    if (successBlock)
        successBlock();
}

#pragma mark - Merge .strings

- (void)mergeStringsWithSuccess:(SuccessBlock)success failed:(FailedBlock)failed
{
    successBlock = success;
    failedBlock = failed;
    
    if ([self.masterStrings count] == 0 || [self.secondaryStrings count] == 0)
    {
        if (failedBlock)
            failedBlock();
        return;
    }
    
    
    // init mergedStrings
    [self.mergedStrings removeAllObjects];
    [self.mergedStrings addObjectsFromArray:self.secondaryStrings];
    
    // add missing fields to mergedStrings
    [self.masterStrings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary*)obj;
        BOOL contains = [self array:self.mergedStrings containsField:[[dict allKeys] firstObject]];
        // add dict with value @""
        if (!contains)
        {
            [self.mergedStrings addObject:@{[[dict allKeys] firstObject] : @""}];
        }
    }];
    
    // sort by alphabetic order
    self.mergedStrings = [self.mergedStrings sortedArrayUsingComparator: ^(id id_1, id id_2) {
        NSDictionary *d1 = (NSDictionary*) id_1;
        NSDictionary *d2 = (NSDictionary*) id_2;
        NSString *s1 = [[d1 allKeys] firstObject];
        NSString *s2 = [[d2 allKeys] firstObject];
        return [s1 compare: s2];
    }].mutableCopy;
    
    if (successBlock)
        successBlock();
}

- (BOOL)array:(NSArray*)array containsField:(NSString*)field
{
    __block BOOL contains = NO;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary*)obj;
        if ([field isEqualToString:[[dict allKeys] firstObject]])
            contains = YES;
    }];
    
    return contains;
}

#pragma mark - Parsing .strings

- (NSAttributedString*)parseArrayToAttributeString:(NSArray*)array
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@""];;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary*)obj;
        NSString *field = [[dict allKeys] firstObject];
        [attrString.mutableString appendString:[NSString stringWithFormat:@"%@", field]];
        [attrString.mutableString appendString:@" = "];
        NSString *value = [[dict allValues] firstObject];
        if ([value isEqualToString:@""])
            [attrString.mutableString appendString:@"\"\""];
        else
            [attrString.mutableString appendString:[NSString stringWithFormat:@"%@", value]];
        [attrString.mutableString appendString:@";"];
        [attrString.mutableString appendString:@"\n"];
    }];
    
    NSDictionary *dict = @{
    NSForegroundColorAttributeName : [NSColor redColor]
    };
    NSRange range = [attrString.string rangeOfString:@"\"\""];
    [attrString setAttributes:dict range:range];

    
    return attrString;
}


- (void)parseMasterStrings:(NSString*)strings
{
    [self.masterStrings removeAllObjects];
    self.masterStrings = [self parseStrings:strings].mutableCopy;
}

- (void)parseSecondaryStrings:(NSString*)strings
{
    [self.secondaryStrings removeAllObjects];
    self.secondaryStrings = [self parseStrings:strings].mutableCopy;
}

- (NSArray*)parseStrings:(NSString*)strings
{
    NSArray *array;
    NSMutableArray *arrayStrings = @[].mutableCopy;
    NSString *trimmedString = [strings stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    // take all the fields and values
    NSArray *list = [trimmedString componentsSeparatedByString:@";"];
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *item = (NSString*)obj;
        NSArray *temp = [item componentsSeparatedByString:@"="];
        if ([temp count] == 2)
        {
            NSDictionary *dict = @{[temp firstObject] : [temp lastObject]};
            [arrayStrings addObject:dict];
        }
    }];
    
    // delete duplicate fields
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:arrayStrings];
    arrayStrings = [orderedSet array].mutableCopy;

    
    // sort by alphabetic order
    array = [arrayStrings sortedArrayUsingComparator: ^(id id_1, id id_2) {
        NSDictionary *d1 = (NSDictionary*) id_1;
        NSDictionary *d2 = (NSDictionary*) id_2;
        NSString *s1 = [[d1 allKeys] firstObject];
        NSString *s2 = [[d2 allKeys] firstObject];
        return [s1 compare: s2];
    }];
    
    
    return array;
}

@end
