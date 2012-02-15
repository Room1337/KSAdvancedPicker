//
//  ViewController.m
//  KSAdvancedPickerDemo
//
//  Created by Davide De Rosa on 10/17/11.
//  Copyright (c) 2011 algoritmico. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void) dealloc
{
    [data release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    data = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < 20; ++i) {
        [data addObject:[NSString stringWithFormat:@"%d", i]];
    }

    CGRect frame;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(20, 20, 728, 350);
    } else {
        frame = CGRectMake(20, 20, 280, 200);
    }

    KSAdvancedPicker *ap = [[KSAdvancedPicker alloc] initWithFrame:frame];
    ap.dataSource = self;
    ap.delegate = self;
    [ap selectRow:4 inComponent:0 animated:YES];
    [self.view addSubview:ap];
    [ap release];

//    for (NSUInteger i = 0; i < [self numberOfComponentsInAdvancedPicker:ap]; ++i) {
//        UITableView *table = [ap tableViewForComponent:i];
//
//        NSLog(@"table[%d] width = %f", i, table.frame.size.width);
//        NSLog(@"table[%d] insets = %@", i, NSStringFromUIEdgeInsets(table.contentInset));
//    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [data release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma mark - KSAdvancedPickerDataSource

- (NSInteger) numberOfComponentsInAdvancedPicker:(KSAdvancedPicker *)picker
{
//    return 1;
    return 3;
}

- (NSInteger) advancedPicker:(KSAdvancedPicker *)picker numberOfRowsInComponent:(NSInteger)component
{
    return [data count];
}

- (UITableViewCell *) advancedPicker:(KSAdvancedPicker *)picker tableView:(UITableView *)tableView cellForRow:(NSInteger)row forComponent:(NSInteger)component
{
    static NSString *identifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
        [cell autorelease];
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [data objectAtIndex:row];
    
//    NSLog(@"cell[%d][%d].frame = %@", component, row, NSStringFromCGRect(cell.frame));

    return cell;
}

- (CGFloat) heightForRowInAdvancedPicker:(KSAdvancedPicker *)picker
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 80;
    } else {
        return 50;
    }
}

- (CGFloat) advancedPicker:(KSAdvancedPicker *)picker widthForComponent:(NSInteger)component
{
    CGFloat width = picker.frame.size.width;

    switch (component) {
        case 0:
            width *= 0.45;
            break;
        case 1:
            width *= 0.25;
            break;
        case 2:
            width *= 0.3;
            break;
        default:
            return 0; // never
    }

//    return width;
    return round(width);
}

#pragma mark - KSAdvancedPickerDelegate

- (void) advancedPicker:(KSAdvancedPicker *)picker didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"selected row %d in component %d", row, component);
}

- (void) advancedPicker:(KSAdvancedPicker *)picker didClickRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"clicked row %d in component %d", row, component);
}

//- (UIView *) backgroundViewForAdvancedPicker:(KSAdvancedPicker *)picker
//{
//    return nil;
//}

- (UIColor *) backgroundColorForAdvancedPicker:(KSAdvancedPicker *)picker
{
    return [UIColor lightGrayColor];
}

//- (UIView *) advancedPicker:(KSAdvancedPicker *)picker backgroundViewForComponent:(NSInteger)component
//{
//    return nil;
//}

- (UIColor *) advancedPicker:(KSAdvancedPicker *)picker backgroundColorForComponent:(NSInteger)component
{
    //    return [UIColor clearColor];
    
    switch (component) {
        case 0:
            return [UIColor colorWithRed:0.5 green:0.5 blue:0.0 alpha:1.0];
        case 1:
            return [UIColor colorWithRed:0.5 green:0.0 blue:0.5 alpha:1.0];
        case 2:
            return [UIColor colorWithRed:0.0 green:0.5 blue:0.5 alpha:1.0];
        default:
            return 0; // never
    }
}

//- (UIView *) viewForAdvancedPickerSelector:(KSAdvancedPicker *)picker
//{
//    return nil;
//}

- (UIColor *) viewColorForAdvancedPickerSelector:(KSAdvancedPicker *)picker
{
    return [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:0.3];
}

@end
