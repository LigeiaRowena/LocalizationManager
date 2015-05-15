

#import <Cocoa/Cocoa.h>

@interface NSScrollView (MultiLine)

- (void)appendStringValue:(NSString*)string;
- (void)setStringValue:(NSString*)string;
- (void)setStringValue:(NSString*)string color:(NSColor*)color range:(NSRange)range;
- (void)setAttributedString:(NSAttributedString*)string;

@end
