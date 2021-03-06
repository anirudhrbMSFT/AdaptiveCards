//
//  ACRChoiceSetViewDataSource.mm
//  ACRChoiceSetViewDataSource
//
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRChoiceSetViewDataSource.h"

using namespace AdaptiveCards;

const CGFloat padding = 16.0f;
const CGFloat accessoryViewWidth = 50.0f;

@implementation ACRChoiceSetViewDataSource
{
    std::shared_ptr<ChoiceSetInput> _choiceSetDataSource;
    NSMutableDictionary *_userSelections;
    NSIndexPath *_lastSelectedIndexPath;
    NSMutableSet *_defaultValuesSet;
    NSArray *_defaultValuesArray;
}

- (instancetype)initWithInputChoiceSet:(std::shared_ptr<AdaptiveCards::ChoiceSetInput> const&)choiceSet
{
    self = [super init];
    if(self)
    {
        self.id = [[NSString alloc]initWithCString:choiceSet->GetId().c_str()
                                           encoding:NSUTF8StringEncoding];
        _isMultiChoicesAllowed = choiceSet->GetIsMultiSelect();
        _choiceSetDataSource = choiceSet;
        _userSelections = [[NSMutableDictionary alloc] init];
        _lastSelectedIndexPath = nil;
        NSString *defaultValues = [NSString stringWithCString:_choiceSetDataSource->GetValue().c_str()
                                                     encoding:NSUTF8StringEncoding];
        _defaultValuesArray = [defaultValues componentsSeparatedByCharactersInSet:
                               [NSCharacterSet characterSetWithCharactersInString:@","]];
        if (_isMultiChoicesAllowed || [_defaultValuesArray count] == 1){
            _defaultValuesSet = [NSMutableSet setWithArray:_defaultValuesArray];
        }
    }
    return self;
}

// ChoiceSetView is a parent view that leads to child view that handles input selection
// so the size is always 1 when there are more than one choices
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (_choiceSetDataSource->GetChoices().size());
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"tabCellId";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    NSString *title = [NSString stringWithCString:_choiceSetDataSource->GetChoices()[indexPath.row]->GetTitle().c_str()
                               encoding:NSUTF8StringEncoding];
    cell.textLabel.text = title;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.adjustsFontSizeToFitWidth = NO;
    NSString *keyForDefaultValue = [NSString stringWithCString:_choiceSetDataSource->GetChoices()[indexPath.row]->GetValue().c_str()
                                                      encoding:NSUTF8StringEncoding];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if([_defaultValuesSet containsObject:keyForDefaultValue]){
        _userSelections[[NSNumber numberWithInteger:indexPath.row]] = [NSNumber numberWithBool:YES];
        [_defaultValuesSet removeObject:keyForDefaultValue];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if this tableView was used before for gathering input,
    // load the tableView with user selection
    if([_userSelections count] &&
       [_userSelections objectForKey:[NSNumber numberWithInteger:indexPath.row]] &&
       [[_userSelections objectForKey:[NSNumber numberWithInteger:indexPath.row]] boolValue] == YES)
    {
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
        [cell setSelected:YES animated:NO];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _lastSelectedIndexPath = indexPath;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isMultiChoicesAllowed) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        _userSelections[[NSNumber numberWithInteger:indexPath.row]] = [NSNumber numberWithBool:YES];
        if (_lastSelectedIndexPath && _lastSelectedIndexPath != indexPath) {
            [self tableView:tableView didDeselectRowAtIndexPath:_lastSelectedIndexPath];
            _lastSelectedIndexPath = nil;
        }
    } else if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        _userSelections[[NSNumber numberWithInteger:indexPath.row]] = [NSNumber numberWithBool:NO];
    } else {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        _userSelections[[NSNumber numberWithInteger:indexPath.row]] = [NSNumber numberWithBool:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    // uncheck selection if multi choice is not allowed
    if (!_isMultiChoicesAllowed) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        _userSelections[[NSNumber numberWithInteger:indexPath.row]] = [NSNumber numberWithBool:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    CGSize labelStringSize =
        [cell.textLabel.text boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width - accessoryViewWidth, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{NSFontAttributeName:cell.textLabel.font}
                                          context:nil].size;
    return labelStringSize.height + padding;
}

- (BOOL)validate:(NSError **)error
{
    // no need to validate
    return YES;
}

- (void)getDefaultInput:(NSMutableDictionary *)dictionary
{
    dictionary[self.id] = [_defaultValuesArray componentsJoinedByString:@";"];
}

- (void)getInput:(NSMutableDictionary *)dictionary
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [_userSelections keyEnumerator];
    NSNumber *key;
    while(key = [enumerator nextObject])
    {
        if([_userSelections[key] boolValue] == YES)
        {
            [values addObject:
             [NSString stringWithCString:_choiceSetDataSource->GetChoices()[[key integerValue]]->GetValue().c_str()
                                encoding:NSUTF8StringEncoding]];
        }
    }
    dictionary[self.id] = [values componentsJoinedByString:@";"];
}

- (NSString *)getTitlesOfChoices
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [_userSelections keyEnumerator];
    NSNumber *key;
    while(key = [enumerator nextObject])
    {
        if([_userSelections[key] boolValue] == YES)
        {
            [values addObject:
             [NSString stringWithCString:_choiceSetDataSource->GetChoices()[[key integerValue]]->GetTitle().c_str()
                                encoding:NSUTF8StringEncoding]];
        }
    }
    if([values count] == 0) {
        return nil;
    }
    return [values componentsJoinedByString:@", "];
}

@end
