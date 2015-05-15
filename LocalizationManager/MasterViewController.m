//
//  MasterViewController.m
//  HelloWorld
//
//  Created by Francesca Corsini on 05/03/15.
//  Copyright (c) 2015 Francesca Corsini. All rights reserved.
//

#import "MasterViewController.h"
#import "NSScrollView+MultiLine.h"
#import "StringsHandler.h"

@interface MasterViewController ()

@property (nonatomic, weak) IBOutlet IRTextFieldDrag *openMasterField;
@property (nonatomic, weak) IBOutlet IRTextFieldDrag *openSecondaryField;
@property (weak) IBOutlet NSScrollView *console;

@end

@implementation MasterViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)loadView
{
	[super loadView];
}

#pragma mark - IRTextFieldDragDelegate

- (void)draggingEntered:(IRTextFieldDrag*)textField
{
	NSLog(@"draggingEntered...");
}

- (void)performDragOperation:(NSString*)text textField:(IRTextFieldDrag*)textField
{
	NSError *err = nil;
	NSString* contents = [NSString stringWithContentsOfFile:text encoding:NSUTF8StringEncoding error:&err];
	NSLog(@"performDragOperation...");
    
    if (textField == self.openMasterField)
    {
        [[StringsHandler sharedInstance] parseMasterStrings:contents];
    }
    
    else if (textField == self.openSecondaryField)
    {
        [[StringsHandler sharedInstance] parseSecondaryStrings:contents];
    }
}

#pragma mark - Parsing .strings


#pragma mark - Actions

- (IBAction)tapOpenMaster:(id)sender
{
	NSOpenPanel *opanel = [NSOpenPanel openPanel];
	NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	[opanel setDirectoryURL:[NSURL fileURLWithPath:documentFolderPath]];
	[opanel setCanChooseFiles:TRUE];
	[opanel setCanChooseDirectories:FALSE];
	[opanel setAllowedFileTypes:@[@"strings"]];
	[opanel setAllowedFileTypes:nil];
	[opanel setPrompt:@"Open"];
	[opanel setTitle:@"Open file"];
	[opanel setMessage:@"Please select a path where to open file"];
	if ([opanel runModal] == NSOKButton)
	{
		NSString* path = [[opanel URL] path];
		NSError *err = nil;
		NSString* contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
		[self.openMasterField setStringValue:path];
        [[StringsHandler sharedInstance] parseMasterStrings:contents];
	}
}

- (IBAction)tapOpenSecondary:(id)sender
{
    NSOpenPanel *opanel = [NSOpenPanel openPanel];
    NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    [opanel setDirectoryURL:[NSURL fileURLWithPath:documentFolderPath]];
    [opanel setCanChooseFiles:TRUE];
    [opanel setCanChooseDirectories:FALSE];
    [opanel setAllowedFileTypes:@[@"strings"]];
    [opanel setAllowedFileTypes:nil];
    [opanel setPrompt:@"Open"];
    [opanel setTitle:@"Open file"];
    [opanel setMessage:@"Please select a path where to open file"];
    if ([opanel runModal] == NSOKButton)
    {
        NSString* path = [[opanel URL] path];
        NSError *err = nil;
        NSString* contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
        [self.openSecondaryField setStringValue:path];
        [[StringsHandler sharedInstance] parseSecondaryStrings:contents];
    }
}


- (IBAction)save:(id)sender
{
	NSSavePanel *spanel = [NSSavePanel savePanel];
	
	NSString *documentFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	[spanel setDirectoryURL:[NSURL fileURLWithPath:documentFolderPath]];
	[spanel setPrompt:@"Save"];
	[spanel setTitle:@"Save file"];
	[spanel setMessage:@"Please select a path where to save file"];
	[spanel setAllowedFileTypes:@[@"strings"]];
		if ([spanel runModal] == NSOKButton)
	{
		NSString* path = [[spanel URL] path];
		NSError *err = nil;
        NSString *stringsToSave = @"test";
		BOOL success = [stringsToSave writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&err];
		if (!success || err)
		{
			[NSApp presentError:err];
		}
	}
}

- (IBAction)clearAll:(id)sender
{
    [self.console setStringValue:@""];
    [self.openMasterField setStringValue:@""];
    [self.openSecondaryField setStringValue:@""];
    
    [[[StringsHandler sharedInstance] masterStrings] removeAllObjects];
    [[[StringsHandler sharedInstance] secondaryStrings] removeAllObjects];
}

@end
