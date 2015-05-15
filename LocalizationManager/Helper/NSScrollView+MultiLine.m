

#import "NSScrollView+MultiLine.h"

@implementation NSScrollView (MultiLine)

- (void)appendStringValue:(NSString*)string
{
    NSTextView *textfield = (NSTextView*)self.documentView;
    NSString *newValue = [textfield.textStorage.mutableString stringByAppendingFormat:@"\n%@", string];
    [textfield setString:newValue];
}

- (void)setStringValue:(NSString*)string
{
    NSTextView *textfield = (NSTextView*)self.documentView;
    [textfield setString:string];
}

- (void)setStringValue:(NSString*)string color:(NSColor*)color range:(NSRange)range
{
    NSTextView *textfield = (NSTextView*)self.documentView;
    [textfield setRichText:YES];
    [textfield setString:string];
    [textfield setTextColor:color range:range];
}

- (void)setAttributedString:(NSAttributedString*)string
{
    NSTextView *textfield = (NSTextView*)self.documentView;
    textfield.font = [NSFont fontWithName:@"Helvetica" size:14];
    [[textfield textStorage] appendAttributedString:string];
}

- (NSString*)getString
{
    NSTextView *textfield = (NSTextView*)self.documentView;
    return textfield.string;
}

@end
