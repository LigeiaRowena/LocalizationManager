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
        [[StringsHandler sharedInstance] diffStringsWithSuccess:^{
            NSAttributedString *attrString = [[StringsHandler sharedInstance] parseArrayToAttributeString:[[StringsHandler sharedInstance] diffStrings]];
            [self.console setAttributedString:attrString];
        } failed:^{
        }];
    }
    
    else if (textField == self.openSecondaryField)
    {
        [[StringsHandler sharedInstance] parseSecondaryStrings:contents];
        [[StringsHandler sharedInstance] diffStringsWithSuccess:^{
            NSAttributedString *attrString = [[StringsHandler sharedInstance] parseArrayToAttributeString:[[StringsHandler sharedInstance] diffStrings]];
            [self.console setAttributedString:attrString];
        } failed:^{
        }];
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
        [[StringsHandler sharedInstance] diffStringsWithSuccess:^{
            NSAttributedString *attrString = [[StringsHandler sharedInstance] parseArrayToAttributeString:[[StringsHandler sharedInstance] diffStrings]];
            [self.console setAttributedString:attrString];
        } failed:^{
        }];
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
        [[StringsHandler sharedInstance] diffStringsWithSuccess:^{
            NSAttributedString *attrString = [[StringsHandler sharedInstance] parseArrayToAttributeString:[[StringsHandler sharedInstance] diffStrings]];
            [self.console setAttributedString:attrString];
        } failed:^{
        }];
    }
}


- (IBAction)save:(id)sender
{
    // resign as first responder the other controls
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    [appDelegate.window makeFirstResponder: nil];
    
    // save diffStrings and ovewrite secondaryStrings with all the diffs
    [[StringsHandler sharedInstance] saveDiffStrings:[self.console getString] success:^{
        [[StringsHandler sharedInstance] saveSecondaryStringsWithSuccess:^{
            NSString *stringToSave = [[StringsHandler sharedInstance] parseArrayToStrings:[[StringsHandler sharedInstance] secondaryStrings]];
            [self showSavePanel:stringToSave];
        } failed:^{
        }];
    } failed:^{
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
    
    [[[StringsHandler sharedInstance] masterStrings] removeAllObjects];
    [[[StringsHandler sharedInstance] secondaryStrings] removeAllObjects];
    [[[StringsHandler sharedInstance] mergedStrings] removeAllObjects];
    [[[StringsHandler sharedInstance] diffStrings] removeAllObjects];
}

@end
