/*
 * KSAdvancedPicker.m
 *
 * Copyright 2011 Davide De Rosa
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "KSAdvancedPicker.h"

@interface KSAdvancedPicker ()

@property (nonatomic, retain) NSMutableArray *tables;
@property (nonatomic, retain) NSMutableArray *selectedRowIndexes;
@property (nonatomic, retain) UIView *overlay;
@property (nonatomic, retain) UIView *selector;

- (NSInteger) componentFromTableView:(UITableView *)tableView;
- (void) alignTableViewToRowBoundary:(UITableView *)tableView;

@end

@implementation KSAdvancedPicker

// public
//@synthesize table;
//@synthesize selectedRowIndex;
@synthesize delegate;

// private
@synthesize tables;
@synthesize selectedRowIndexes;
@synthesize overlay;
@synthesize selector;

- (id) initWithFrame:(CGRect)frame delegate:(id<KSAdvancedPickerDelegate>)aDelegate
{
    if ((self = [super initWithFrame:frame])) {
        delegate = aDelegate;

        // custom row height?
        CGFloat rowHeight;
        if ([delegate respondsToSelector:@selector(heightForRowInAdvancedPicker:)]) {
            rowHeight = [delegate heightForRowInAdvancedPicker:self];
        } else {
            rowHeight = 44;
        }

        // distance from center
        const CGFloat centralRowOffset = (frame.size.height - rowHeight) / 2;

        // LEGACY: remove respondsToSelector later, this is a required method
        NSInteger components = 1;
        if ([delegate respondsToSelector:@selector(numberOfComponentsInAdvancedPicker:)]) {
            components = [delegate numberOfComponentsInAdvancedPicker:self];
        }

        // picker background
        if ([delegate respondsToSelector:@selector(backgroundViewForAdvancedPicker:)]) {
            UIView *backgroundView = [delegate backgroundViewForAdvancedPicker:self];
            [self addSubview:backgroundView];
            [self sendSubviewToBack:backgroundView];
        } else if ([delegate respondsToSelector:@selector(backgroundColorForAdvancedPicker:)]) {
            self.backgroundColor = [delegate backgroundColorForAdvancedPicker:self];
        }
        
        // picker content
        tables = [[NSMutableArray alloc] init];
        selectedRowIndexes = [[NSMutableArray alloc] init];
        CGRect tableFrame = CGRectMake(0, 0, 0, self.bounds.size.height);
        for (NSInteger i = 0; i < components; ++i) {

            // optional width
            if ([delegate respondsToSelector:@selector(advancedPicker:widthForComponent:)]) {
                tableFrame.size.width = [delegate advancedPicker:self widthForComponent:i];
            } else {
                tableFrame.size.width = round(frame.size.width / components);
            }

            // component table
            UITableView *table = [[UITableView alloc] initWithFrame:tableFrame];
            table.rowHeight = rowHeight;
            table.contentInset = UIEdgeInsetsMake(centralRowOffset, 0, centralRowOffset, 0);
            table.separatorStyle = UITableViewCellSeparatorStyleNone;
            table.showsVerticalScrollIndicator = NO;

            // component background
            if ([delegate respondsToSelector:@selector(advancedPicker:backgroundViewForComponent:)]) {
                table.backgroundView = [delegate advancedPicker:self backgroundViewForComponent:i];
            } else if ([delegate respondsToSelector:@selector(advancedPicker:backgroundColorForComponent:)]) {
                table.backgroundColor = [delegate advancedPicker:self backgroundColorForComponent:i];
            } else {
                table.backgroundColor = [UIColor clearColor];
            }

            table.dataSource = self;
            table.delegate = self;
            [self addSubview:table];

            [tables addObject:table];
            [selectedRowIndexes addObject:[NSNumber numberWithInteger:0]]; // first row selected by default
            [table release];

            // next component offset
            tableFrame.origin.x += tableFrame.size.width;
        }
        
        // optional overlay
        if ([delegate respondsToSelector:@selector(overlayViewForAdvancedPickerSelector:)]) {
            self.overlay = [delegate overlayViewForAdvancedPickerSelector:self];
        } else if ([delegate respondsToSelector:@selector(overlayColorForAdvancedPickerSelector:)]) {
            overlay = [[UIView alloc] init];
            overlay.backgroundColor = [delegate overlayColorForAdvancedPickerSelector:self];
        }

        if (overlay) {

            // ignore user input on selector
            overlay.userInteractionEnabled = NO;

            // fill parent
            overlay.frame = self.bounds;
            [self addSubview:overlay];
        }

        // custom selector?
        if ([delegate respondsToSelector:@selector(viewForAdvancedPickerSelector:)]) {
            self.selector = [delegate viewForAdvancedPickerSelector:self];
        } else if ([delegate respondsToSelector:@selector(viewColorForAdvancedPickerSelector:)]) {
            selector = [[UIView alloc] init];
            selector.backgroundColor = [delegate viewColorForAdvancedPickerSelector:self];
        } else {
            selector = [[UIView alloc] init];
            selector.backgroundColor = [UIColor blackColor];
            selector.alpha = 0.3;
        }
        
        // ignore user input on selector
        selector.userInteractionEnabled = NO;
        
        // override selector frame
        CGRect selectorFrame;
        selectorFrame.origin.x = 0;
        selectorFrame.origin.y = centralRowOffset;
        selectorFrame.size.width = frame.size.width;
        selectorFrame.size.height = rowHeight;
        selector.frame = selectorFrame;

        [self addSubview:selector];
        
//        NSLog(@"self.frame = %@", NSStringFromCGRect(self.frame));
//        NSLog(@"table.frame = %@", NSStringFromCGRect(table.frame));
//        NSLog(@"selector.frame = %@", NSStringFromCGRect(selector.frame));
    }
    return self;
}

- (void) dealloc
{
    self.delegate = nil;
    self.tables = nil;
    self.selectedRowIndexes = nil;
    self.overlay = nil;
    self.selector = nil;

    [super dealloc];
}

// deprecated
- (UITableView *) table
{
    return [tables objectAtIndex:0];
}

// deprecated
- (NSInteger) selectedRowIndex
{
    return [self selectedRowInComponent:0];
}

// deprecated
- (void) scrollToRowAtIndex:(NSInteger)rowIndex animated:(BOOL)animated
{
    [self selectRow:rowIndex inComponent:0 animated:animated];
}

- (UITableView *) tableViewForComponent:(NSInteger)component
{
    return [tables objectAtIndex:component];
}

- (NSInteger) selectedRowInComponent:(NSInteger)component
{
    return [[selectedRowIndexes objectAtIndex:component] integerValue];
}

- (void) selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
{
    [selectedRowIndexes replaceObjectAtIndex:component withObject:[NSNumber numberWithInteger:row]];
    
    UITableView *table = [tables objectAtIndex:component];

    const CGPoint alignedOffset = CGPointMake(0, row * table.rowHeight - table.contentInset.top);
    [table setContentOffset:alignedOffset animated:animated];
    
    // LEGACY: backwards compatibility
    if ([delegate respondsToSelector:@selector(advancedPicker:didSelectRow:inComponent:)]) {
        [delegate advancedPicker:self didSelectRow:row inComponent:component];
    } else if ([delegate respondsToSelector:@selector(advancedPicker:didSelectRowAtIndex:)]) {
        [delegate advancedPicker:self didSelectRowAtIndex:row];
    }
}

- (void) reloadData
{
    for (UITableView *table in tables) {
        [table reloadData];
    }
}

- (void) reloadDataInComponent:(NSInteger)component
{
    [[tables objectAtIndex:component] reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // LEGACY: remove respondsToSelector later, this is a required method
    if ([delegate respondsToSelector:@selector(advancedPicker:numberOfRowsInComponent:)]) {
        const NSInteger component = [self componentFromTableView:tableView];
        return [delegate advancedPicker:self numberOfRowsInComponent:component];
    } else {
        return [delegate numberOfRowsInAdvancedPicker:self];
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // LEGACY: remove respondsToSelector later, this is a required method
    UITableViewCell *cell = nil;
    if ([delegate respondsToSelector:@selector(advancedPicker:tableView:cellForRow:forComponent:)]) {
        const NSInteger component = [self componentFromTableView:tableView];
        cell = [delegate advancedPicker:self tableView:tableView cellForRow:indexPath.row forComponent:component];
    } else {
        cell = [delegate advancedPicker:self tableView:tableView cellForRowAtIndex:indexPath.row];
    }

    // allow selection but keep invisible
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    const NSInteger component = [self componentFromTableView:tableView];

    // call upon animation end?
    // LEGACY: backwards compatibility
    if ([delegate respondsToSelector:@selector(advancedPicker:didClickRow:inComponent:)]) {
        [delegate advancedPicker:self didClickRow:indexPath.row inComponent:component];
    } else if ([delegate respondsToSelector:@selector(advancedPicker:didClickRowAtIndex:)]) {
        [delegate advancedPicker:self didClickRowAtIndex:indexPath.row];
    }

    [self selectRow:indexPath.row inComponent:component animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self alignTableViewToRowBoundary:(UITableView *)scrollView];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self alignTableViewToRowBoundary:(UITableView *)scrollView];
}

#pragma mark - Private methods

- (NSInteger) componentFromTableView:(UITableView *)tableView
{
    return [tables indexOfObject:tableView];
}

- (void) alignTableViewToRowBoundary:(UITableView *)tableView
{
//    NSLog(@"contentOffset = %@", NSStringFromCGPoint(tableView.contentOffset));
//    NSLog(@"rowHeight = %f", tableView.rowHeight);

    const CGPoint relativeOffset = CGPointMake(0, tableView.contentOffset.y + tableView.contentInset.top);
//    NSLog(@"relativeOffset = %@", NSStringFromCGPoint(relativeOffset));

    const NSUInteger row = round(relativeOffset.y / tableView.rowHeight);
//    NSLog(@"row = %d", row);

    const NSInteger component = [self componentFromTableView:tableView];
    [self selectRow:row inComponent:component animated:YES];
}

@end
