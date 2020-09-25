/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import CoreData


extension Section {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Section> {
        return NSFetchRequest<Section>(entityName: Section.entityName)
    }

    @NSManaged public var name: String?
    @NSManaged public var shortcuts: NSOrderedSet?

}

// MARK: Generated accessors for shortcuts
extension Section {

    @objc(insertObject:inShortcutsAtIndex:)
    @NSManaged public func insertIntoShortcuts(_ value: Shortcut, at idx: Int)

    @objc(removeObjectFromShortcutsAtIndex:)
    @NSManaged public func removeFromShortcuts(at idx: Int)

    @objc(insertShortcuts:atIndexes:)
    @NSManaged public func insertIntoShortcuts(_ values: [Shortcut], at indexes: NSIndexSet)

    @objc(removeShortcutsAtIndexes:)
    @NSManaged public func removeFromShortcuts(at indexes: NSIndexSet)

    @objc(replaceObjectInShortcutsAtIndex:withObject:)
    @NSManaged public func replaceShortcuts(at idx: Int, with value: Shortcut)

    @objc(replaceShortcutsAtIndexes:withShortcuts:)
    @NSManaged public func replaceShortcuts(at indexes: NSIndexSet, with values: [Shortcut])

    @objc(addShortcutsObject:)
    @NSManaged public func addToShortcuts(_ value: Shortcut)

    @objc(removeShortcutsObject:)
    @NSManaged public func removeFromShortcuts(_ value: Shortcut)

    @objc(addShortcuts:)
    @NSManaged public func addToShortcuts(_ values: NSOrderedSet)

    @objc(removeShortcuts:)
    @NSManaged public func removeFromShortcuts(_ values: NSOrderedSet)

}
