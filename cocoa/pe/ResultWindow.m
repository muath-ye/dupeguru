/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "ResultWindow.h"
#import "Dialogs.h"
#import "ProgressController.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "Consts.h"

@implementation ResultWindow
/* Override */
- (id)initWithParentApp:(AppDelegateBase *)aApp;
{
    self = [super initWithParentApp:aApp];
    NSMutableIndexSet *deltaColumns = [NSMutableIndexSet indexSetWithIndex:2];
    [deltaColumns addIndex:5];
    [table setDeltaColumns:deltaColumns];
    return self;
}

/* Actions */
- (IBAction)clearPictureCache:(id)sender
{
    if ([Dialogs askYesNo:@"Do you really want to remove all your cached picture analysis?"] == NSAlertSecondButtonReturn) // NO
        return;
    [(PyDupeGuru *)py clearPictureCache];
}

- (IBAction)resetColumnsToDefault:(id)sender
{
    NSMutableArray *columnsOrder = [NSMutableArray array];
    [columnsOrder addObject:@"0"];
    [columnsOrder addObject:@"1"];
    [columnsOrder addObject:@"2"];
    [columnsOrder addObject:@"4"];
    [columnsOrder addObject:@"6"];
    NSMutableDictionary *columnsWidth = [NSMutableDictionary dictionary];
    [columnsWidth setObject:i2n(162) forKey:@"0"];
    [columnsWidth setObject:i2n(142) forKey:@"1"];
    [columnsWidth setObject:i2n(63) forKey:@"2"];
    [columnsWidth setObject:i2n(73) forKey:@"4"];
    [columnsWidth setObject:i2n(58) forKey:@"6"];
    [self restoreColumnsPosition:columnsOrder widths:columnsWidth];
}

- (IBAction)startDuplicateScan:(id)sender
{
    if ([py resultsAreModified]) {
        if ([Dialogs askYesNo:@"You have unsaved results, do you really want to continue?"] == NSAlertSecondButtonReturn) // NO
            return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    PyDupeGuru *_py = (PyDupeGuru *)py;
    [_py setMinMatchPercentage:[ud objectForKey:@"minMatchPercentage"]];
    [_py setMixFileKind:n2b([ud objectForKey:@"mixFileKind"])];
    [_py setIgnoreHardlinkMatches:n2b([ud objectForKey:@"ignoreHardlinkMatches"])];
    [_py setMatchScaled:[ud objectForKey:@"matchScaled"]];
    int r = n2i([py doScan]);
    if (r != 0) {
        [[ProgressController mainProgressController] hide];
    }
    if (r == 3) {
        [Dialogs showMessage:@"The selected directories contain no scannable file."];
    }
    if (r == 4) {
        [Dialogs showMessage:@"The iPhoto application couldn't be found."];
    }
}

/* Public */
- (void)initResultColumns
{
    NSTableColumn *refCol = [matches tableColumnWithIdentifier:@"0"];
    _resultColumns = [[NSMutableArray alloc] init];
    [_resultColumns addObject:[matches tableColumnWithIdentifier:@"0"]]; // File Name
    [_resultColumns addObject:[self getColumnForIdentifier:1 title:@"Directory" width:120 refCol:refCol]];
    NSTableColumn *sizeCol = [self getColumnForIdentifier:2 title:@"Size (KB)" width:63 refCol:refCol];
    [[sizeCol dataCell] setAlignment:NSRightTextAlignment];
    [_resultColumns addObject:sizeCol];
    [_resultColumns addObject:[self getColumnForIdentifier:3 title:@"Kind" width:40 refCol:refCol]];
    [_resultColumns addObject:[self getColumnForIdentifier:4 title:@"Dimensions" width:80 refCol:refCol]];
    [_resultColumns addObject:[self getColumnForIdentifier:5 title:@"Modification" width:120 refCol:refCol]];
    [_resultColumns addObject:[self getColumnForIdentifier:6 title:@"Match %" width:58 refCol:refCol]];
    [_resultColumns addObject:[self getColumnForIdentifier:7 title:@"Dupe Count" width:80 refCol:refCol]];
}
@end