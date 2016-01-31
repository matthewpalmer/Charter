# DSNestedAccordion

A nested accordion view for Cocoa Touch

# Demo
![DSNestedAccordion iPhone demo](https://dl.dropboxusercontent.com/s/rbszupheigunp5v/DSNestedAccordion_demo.gif "DSNestedAccordion iPhone demo Video")

## Current Version

Version: 0.1.0

## Under the Hood

* Pluggable and decoupled from user interface layer
* Supports infinite levels of nesting
* Uses ARC (Automatic Reference Counting)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Extend DSNestedAccordionHandler

DSNestedAccordionHandler provides abstract implementation of UITableViewDataSource and UITableViewDelegate with
support for nesting table views

```objective-c
#import "DSNestedAccordionHandler.h"

@interface DSBeerTableViewHandler : DSNestedAccordionHandler

@end
```
### Implement 3 datasource methods

```objective-c
- (NSInteger)noOfRowsInRootLevel;

- (NSInteger)tableView:(UITableView *)view noOfChildRowsForCellAtPath:(DSCellPath *)path;

- (UITableViewCell *)tableView:(UITableView *)view cellForPath:(DSCellPath *)path;
```

DSCellPath represents the traversal path to the cell from the root level within a nested model. *levelIndexes* array property will hold the indices of the parent cells at each nesting level.


For example, levelIndexes having a value @[1, 2, 0] would identify the path *vertibrate > bird > duck* in the below example data.

* invertebrate
 * worm
   * fluke, hookworm, earthworm
 * arthropod
   * crab, spider, shrimp
* vertebrate
 * amphibian
   * frog, crocodile
 * mammal
   * dog, cat, lion, tiger
 * bird
   * duck, pigeon, peacock, parrot

#### Example implementation

```objective-c
- (NSInteger)noOfRowsInRootLevel {
    return _beers.allFlavors.count;
}
```
```objective-c
- (NSInteger)tableView:(UITableView *)view noOfChildRowsForCellAtPath:(DSCellPath *)path {
    switch (path.levelIndexes.count) {
        case 1:
            return [self noOfBeerStylesForFlavorAtIndex:[path.levelIndexes[0] integerValue]];
        case 2:
            return [self noOfNotableBeerStylesForStyleAtIndex:[path.levelIndexes[1] integerValue] withFlavorAtIndex:[path.levelIndexes[0] integerValue]];
        default:
            0;
    }
    return 0;
}
```
```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForPath:(DSCellPath *)path {
    switch (path.levelIndexes.count) {
        case 1:
            return [self tableView:tableView cellForBeerFlavorAtIndex:[path.levelIndexes[0] integerValue]];
        case 2:
            return [self tableView:tableView cellForBeerStyleAtIndex:[path.levelIndexes[1] integerValue] withFlavorWithIndex:[path.levelIndexes[0] integerValue]];
        default:
            return [self tableView:tableView cellForNotableBeerStyleAtIndex:[path.levelIndexes[2] integerValue] ofStyleWithIndex:[path.levelIndexes[1] integerValue] withFlavorWithIndex:[path.levelIndexes[0] integerValue]];
    }
}
```

## Requirements

iOS 6

## Installation

DSNestedAccordion is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DSNestedAccordion"

## Author

deepan, emaildeepan@yahoo.co.in

## Contact
If you have any questions comments or suggestions, send me a message. If you find a bug, or want to submit a pull request, let me know.

* emaildeepan@yahoo.co.in
* http://twitter.com/s_deepan

## License

DSNestedAccordion is available under the MIT license. See the LICENSE file for more info.

## Credits

The demo concept was inspired from [this article](http://www.splendidtable.org/story/the-7-flavor-categories-of-beer-what-they-are-how-to-pair-them) published by http://www.splendidtable.org/
