# Changelog

## 0.0.2

`UITableView` & `UICollectionView` binding improvements, including:
  - Fix bug with `UITableView` selection handling where tapping the same row 
    multiple times would add it to the list of selections multiple times
  - Added support for disabling selection of specific items in (see 
  	`DataSource.disableSectionFor(...)`)
  - Added `DataSource.selection` - for working with single selection

## 0.0.1

Initial release
