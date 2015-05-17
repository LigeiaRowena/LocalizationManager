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
#import "AppDelegate.h"

@interface MasterViewController ()

@property (nonatomic, weak) IBOutlet IRTextFieldDrag *openMasterField;
@property (nonatomic, weak) IBOutlet IRTextFieldDrag *openSecondaryField;
@property (weak) IBOutlet NSScrollView *console;
@property (weak) IBOutlet NSSegmentedControl *filterStrings;

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
	
	// set default value of the filter: show only diff strings
	[self.filterStrings setSelected:YES forSegment:0];
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
		[self filter:nil];
	}
	
    else if (textField == self.openSecondaryField)
    {
        [[StringsHandler sharedInstance] parseSecondaryStrings:contents];
		[self filter:nil];
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
		[self filter:nil];
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
		[self filter:nil];
	}
}

- (IBAction)filter:(id)sender
{
	// Filter by diff strings
	if (self.filterStrings.selectedSegment == 0)
	{
		[self showDiffStrings];
	}
	
	// Filter by merged strings
	else if (self.filterStrings.selectedSegment == 1)
	{
		[self showMergedStrings];
	}
}

- (void)showDiffStrings
{
	// clean
	[self.console setStringValue:@""];
	
	[[StringsHandler sharedInstance] diffStringsWithSuccess:^{
		NSAttributedString *attrString = [[StringsHandler sharedInstance] parseArrayToAttributeString:[[StringsHandler sharedInstance] diffStrings]];
		[self.console setAttributedString:attrString];
	} failed:^{
	}];
}

- (void)showMergedStrings
{
	// clean
	[self.console setStringValue:@""];

	[[StringsHandler sharedInstance] mergeStringsWithSuccess:^{
		NSAttributedString *attrString = [[StringsHandler sharedInstance] parseArrayToAttributeString:[[StringsHandler sharedInstance] mergedStrings]];
		[self.console setAttributedString:attrString];
	} failed:^{
	}];
}

- (IBAction)save:(id)sender
{
    // resign as first responder the other controls
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    [appDelegate.window makeFirstResponder: nil];
	
	
    // save mergedStrings
	[[StringsHandler sharedInstance] saveStrings:[self.console getString] isDiff:(self.filterStrings.selectedSegment == 0) success:^{
		NSString *stringToSave = [[StringsHandler sharedInstance] parseArrayToStrings:[[StringsHandler sharedInstance] mergedStrings]];
		[self showSavePanel:stringToSave];
	} failed:^{
		[self showAlertOfKind:NSCriticalAlertStyle WithTitle:@"Error" AndMessage:@"There aren't differences to save"];
	}];
}



- (void)showSavePanel:(NSString*)strings
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
        BOOL success = [strings writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:&err];
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
	[self.filterStrings setSelected:YES forSegment:0];
    
    [[[StringsHandler sharedInstance] masterStrings] removeAllObjects];
    [[[StringsHandler sharedInstance] secondaryStrings] removeAllObjects];
    [[[StringsHandler sharedInstance] mergedStrings] removeAllObjects];
    [[[StringsHandler sharedInstance] diffStrings] removeAllObjects];
}

#pragma mark - Alert Methods

- (void)showAlertOfKind:(NSAlertStyle)style WithTitle:(NSString *)title AndMessage:(NSString *)message
{
	// Show a critical alert
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:title];
	[alert setInformativeText:message];
	[alert setAlertStyle:style];
	[alert runModal];
}

@end
