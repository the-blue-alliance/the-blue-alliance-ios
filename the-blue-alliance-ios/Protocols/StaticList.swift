//
//  StaticList.swift
//  JadKit
//
//  Created by Jad Osseiran on 7/25/15.
//  Copyright © 2016 Jad Osseiran. All rights reserved.
//
//  --------------------------------------------
//
//  Implements the protocol and their extensions to get a simple non-fetched list going.
//
//  --------------------------------------------
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//  this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import UIKit

/**
 The basic beahviour that a non fetched list needs to implement. This is
 rather basic, as all a non-fetched list really needs is a data source.
 */
public protocol StaticList: List {
  /// The list data used to populate the list. This an array  to
  /// populate the rows. Currently this is limited to a single section.
  var listData: [[Object]]! { get set }
}

/**
 Protocol extension to implement the basic non fetched list methods.
 */
public extension StaticList {
  /// The number of sections in the `listData`.
  var sectionCount: Int {
    return listData?.count ?? 0
  }
  
  /**
   The number of items in a section of the `listData`.
   - parameter section: The section in which the row count will be returned.
   - returns: The number of items in a given section. `0` if the section is
   not found.
   */
  func itemCount(at section: Int) -> Int {
    guard listData != nil && section >= 0 && section < listData!.count else {
      return 0
    }
    return listData![section].count
  }
  
  /**
   Convenient helper method to find the object at a given index path.
   This method works well with `isValidIndexPath:`.
   - note: This method is implemented by a protocol extension if the object
   conforms to either `DynamicList` or `StaticList`
   - parameter indexPath: The index path to retreive the object for.
   - returns: An optional with the corresponding object at an index
   path or nil if the index path is invalid.
   */
  func object(at indexPath: IndexPath) -> Object? {
    guard isValid(indexPath: indexPath) else {
      return nil
    }
    return listData?[indexPath.section][indexPath.row]
  }

  /**
   Conveneient helper method to ensure that a given index path is valid.
   - note: This method is implemented by a protocol extension if the object
   conforms to either `DynamicList` or `StaticList`
   - parameter indexPath: The index path to check for existance.
   - returns: `true` iff the index path is valid for your data source.
   */
  func isValid(indexPath: IndexPath) -> Bool {
    guard listData != nil && indexPath.section >= 0 && indexPath.section < listData!.count else {
      return false
    }
    return indexPath.row >= 0 && indexPath.row < listData![indexPath.section].count
  }
}

// MARK: Table

/**
 Empty protocol to set up the conformance to the various protocols to allow
 for a valid table view protocol extension implementation.
 */
public protocol StaticTableList: StaticList, UITableViewDataSource, UITableViewDelegate {
  /// The table view that will present the data.
  var tableView: UITableView! { get set }
}

/**
 Protocol extension to implement the table view delegate & data source methods.
 */
public extension StaticTableList where ListView == UITableView, Cell == UITableViewCell {
  /**
   Method to call in `tableView:cellForRowAtIndexPath:`.
   - parameter indexPath: An index path locating a row in `tableView`
   */
  func cell(at indexPath: IndexPath) -> UITableViewCell {
    let identifier = cellIdentifier(at: indexPath)
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                           for: indexPath)

    if let object = object(at: indexPath) {
      listView(tableView, configureCell: cell, withObject: object, atIndexPath: indexPath)
    }

    return cell
  }

  /**
   Method to call in `tableView:didSelectRowAtIndexPath:`.
   - parameter indexPath: An index path locating the new selected row in `tableView`.
   */
  func didSelectItem(at indexPath: IndexPath) {
    if let object = object(at: indexPath) {
      listView(tableView, didSelectObject: object, atIndexPath: indexPath)
    }
  }
}

// MARK: Collection

/**
 Empty protocol to set up the conformance to the various protocols to allow
 for a valid collection view protocol extension implementation.
 */
public protocol StaticCollectionList: StaticList, UICollectionViewDataSource,
  UICollectionViewDelegate {
    /// The collection view that will present the data.
    var collectionView: UICollectionView? { get set }
}

/**
 Protocol extension to implement the collection view delegate & data
 source methods.
 */
public extension StaticCollectionList where ListView == UICollectionView, Cell == UICollectionViewCell {
  /**
   Method to call in `collectionView:cellForItemAtIndexPath:`.
   - parameter indexPath: The index path that specifies the location of the item.
   */
  func cell(at indexPath: IndexPath) -> UICollectionViewCell {
    let identifier = cellIdentifier(at: indexPath)

    let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: identifier,
                                                                     for: indexPath)

    if let object = object(at: indexPath) {
      listView(collectionView!, configureCell: cell, withObject: object, atIndexPath: indexPath)
    }

    return cell
  }

  /**
   Method to call in `collectionView:didSelectItemAtIndexPath:`.
   - parameter indexPath: The index path of the cell that was selected.
   */
  func didSelectItem(at indexPath: IndexPath) {
    if let object = object(at: indexPath) {
      listView(collectionView!, didSelectObject: object, atIndexPath: indexPath)
    }
  }
}
