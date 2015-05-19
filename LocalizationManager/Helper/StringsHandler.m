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

- (NSString*)removeSlantingDoubleQuoteFromString:(NSString*)string
{
    NSMutableString *str = @"".mutableCopy;
    NSRange range = NSMakeRange(0, 1);
    for (__unused int i = (int)range.location; range.location < [string length]; range.location++)
    {
        NSString *substring = [string substringWithRange:range];
        if ([substring isEqualToString:@"”"] || [substring isEqualToString:@"“"])
            [str appendString:@"\""];
        else
            [str appendString:substring];
    }
    
    return str;
}

#pragma mark - Save .strings

- (void)saveStrings:(NSString*)strings isDiff:(BOOL)isDiff success:(SuccessBlock)success failed:(FailedBlock)failed
{
	successBlock = success;
	failedBlock = failed;
    
    
    if ([self.masterStrings count] == 0 || [self.secondaryStrings count] == 0)
    {
        if (failedBlock)
            failedBlock(@"Please insert a proper master .strings file and a proper secondary .strings file.");
        return;
    }
    
    // delete eventually slanting double quote
    NSString *standardString = [self removeSlantingDoubleQuoteFromString:strings];

    
    // detect if strings is regular
    if (![self detectRegularStrings:standardString])
    {
        if (failedBlock)
            failedBlock(@"You edited a not valid .strings file. Please try again.");
        return;
    }
	
	// save mergedStrings
	[self.diffStrings removeAllObjects];
	[self.mergedStrings removeAllObjects];
	if (isDiff)
	{
        self.diffStrings = [self parseStrings:standardString].mutableCopy;
		[self.mergedStrings addObjectsFromArray:self.secondaryStrings];
		[self.mergedStrings addObjectsFromArray:self.diffStrings];
	}
	else
		self.mergedStrings = [self parseStrings:standardString].mutableCopy;
	
	// sort mergedStrings by alphabetic order
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

#pragma mark - Diff .strings

- (void)diffStringsWithSuccess:(SuccessBlock)success
{
    successBlock = success;
    
    if ([self.masterStrings count] == 0 || [self.secondaryStrings count] == 0)
    {
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

- (void)mergeStringsWithSuccess:(SuccessBlock)success
{
    successBlock = success;
    
    if ([self.masterStrings count] == 0 || [self.secondaryStrings count] == 0)
    {
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
        [attrString.mutableString appendString:[NSString stringWithFormat:@"\"%@\"", field]];
        [attrString.mutableString appendString:@" = "];
        NSString *value = [[dict allValues] firstObject];
        [attrString.mutableString appendString:[NSString stringWithFormat:@"\"%@\"", value]];
        [attrString.mutableString appendString:@";"];
        [attrString.mutableString appendString:@"\n"];
    }];
    
    NSDictionary *dict = @{
    NSForegroundColorAttributeName : [NSColor redColor],
	NSFontAttributeName : [NSFont fontWithName:@"Helvetica" size:14]
    };
    NSRange range = [attrString.string rangeOfString:@"\"\""];
    [attrString setAttributes:dict range:range];

    
    return attrString;
}

- (NSString*)parseArrayToStrings:(NSArray*)array
{
    NSMutableString *string = @"".mutableCopy;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary*)obj;
        NSString *field = [[dict allKeys] firstObject];
        [string appendString:[NSString stringWithFormat:@"%@", field]];
        [string appendString:@" = "];
        NSString *value = [[dict allValues] firstObject];
        if ([value isEqualToString:@""])
            [string appendString:@"\"\""];
        else
            [string appendString:[NSString stringWithFormat:@"%@", value]];
        [string appendString:@";"];
        [string appendString:@"\n"];
    }];
    
    return string;
}

- (void)parseMasterStringsFromPath:(NSString*)path
{
    [self.masterStrings removeAllObjects];
    self.masterStrings = [self parseStringsFromPath:path].mutableCopy;
}

- (void)parseSecondaryStringsFromPath:(NSString*)path
{
    [self.secondaryStrings removeAllObjects];
    self.secondaryStrings = [self parseStringsFromPath:path].mutableCopy;
}

- (BOOL)detectRegularStrings:(NSString*)strings
{
    __block BOOL isRegular = YES;
    NSString *trimmedString = [strings stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSDictionary *dict;
    
    @try {
        dict = [trimmedString propertyListFromStringsFileFormat];
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
    }
    
  
    /*
     
    NSArray *list = [trimmedString componentsSeparatedByString:@";"];
    if ([list count] < 2)
        return NO;
    
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *item = (NSString*)obj;
        NSArray *field = [item componentsSeparatedByString:@"="];
        if ([field count] == 2)
        {
            for (NSString *string in field)
            {
                BOOL hasPrefix = ([string hasPrefix:@"\""]) || ([string hasPrefix:@"”"]);
                BOOL hasSuffix = ([string hasSuffix:@"\""]) || ([string hasSuffix:@"”"]);
                if (hasPrefix && hasSuffix)
                {
                    NSLog(@"dfsdfsdfsdf");
                }
                else
                {
                    isRegular = NO;
                    *stop = YES;
                }
            }
        }
        else
        {
            isRegular = NO;
            *stop = YES;
        }
    }];
     */

    
    
    return isRegular;
}

- (NSArray*)parseStringsFromPath:(NSString*)path
{
    NSArray *array;
    NSMutableArray *arrayStrings = @[].mutableCopy;
    
    // take all the fields and values
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [arrayStrings addObject:@{key : obj}];
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

- (NSArray*)parseStrings:(NSString*)strings
{
    NSArray *array;
    NSMutableArray *arrayStrings = @[].mutableCopy;
    NSString *trimmedString = [strings stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    // take all the fields and values
    NSDictionary *dict = [trimmedString propertyListFromStringsFileFormat];;
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [arrayStrings addObject:@{key : obj}];
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
