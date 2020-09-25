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


import UIKit
import CoreData

class ShortcutsViewController: UIViewController {
  
  var isFiltered = false
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var filterButton: UIBarButtonItem!
  
  @IBInspectable var number: Int = 0
  
  lazy var managedObjectContext: NSManagedObjectContext = {
    return CoreDataStack.moc
  }()
  
  lazy var fetchedResultsController: NSFetchedResultsController<Shortcut> = {
    let fetchRequest: NSFetchRequest<Shortcut> = Shortcut.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: Section.sortByNameKey,
                                                     ascending: true)]
    let fetchedResultsController =
      NSFetchedResultsController(fetchRequest: fetchRequest,
                                 managedObjectContext: self.managedObjectContext,
                                 sectionNameKeyPath: Section.sortByNameKey,
                                 cacheName: nil)
    fetchedResultsController.delegate = self
    return fetchedResultsController
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    filter()
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 140
  }
  
  func filter() {
    let fetchRequest = fetchedResultsController.fetchRequest
    let predicate: NSPredicate?
    if isFiltered {
      filterButton.tintColor = UIColor(asset: .navigationSecondary)
      predicate = nil
      
    } else {
      filterButton.tintColor = UIColor(asset: .navigationPrimary)
      predicate = NSPredicate(format: "\(Shortcut.filterByKey) == %@", NSNumber(value: Filter.none.rawValue))
    }
    
    

    fetchRequest.predicate = predicate
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Data Fetch Error")
    }
    isFiltered = !isFiltered
  }
  
  @IBAction func btnFilter(_ button: UIBarButtonItem) {
    filter()
    tableView.reloadData()
  }
  
  @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
  }
  
  @IBAction func saveShortcut(segue: UIStoryboardSegue) {
    if let controller = segue.source as? ShortcutDetailViewController {
      let shortcut: Shortcut?
      if controller.state == .add {
        shortcut = managedObjectContext.insert() as Shortcut
      } else {
        shortcut = controller.shortcut
      }
      shortcut?.keyboardShortcut = controller.keyboardShortcut.text
      shortcut?.shortcutDescription = controller.shortcutDescription.text
      shortcut?.section = controller.section
      managedObjectContext.saveContext()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? UINavigationController {
      if let controller = destination.viewControllers[0] as? ShortcutDetailViewController {
        controller.managedObjectContext = managedObjectContext
        if (sender as? UITableViewCell) != nil {
          controller.state = .edit
          if let path = tableView.indexPathForSelectedRow {
            controller.shortcut = fetchedResultsController.object(at: path)
          }
        } else {
          controller.state = .add
          controller.shortcut = nil
        }
      }
    }
  }
}

extension ShortcutsViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 60
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShortcutCell", for: indexPath) as? ShortcutsTableViewCell else {
      fatalError("can't dequeue Shortcuts Cell")
    }
    let shortcut = fetchedResultsController.object(at: indexPath)
    cell.shortcut = shortcut
    cell.managedObjectContext = managedObjectContext
    cell.shortcutLabel.text = shortcut.keyboardShortcut
    cell.descriptionLabel.text = shortcut.shortcutDescription
    cell.checkbox.checked = shortcut.filter
    
    cell.shortcutLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    cell.descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
    
    return cell
  }
  
  
  
  func numberOfSections(in tableView: UITableView) -> Int {
    guard let sections = fetchedResultsController.sections else {
      return 0
    }
    return sections.count
    
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let shortcuts = fetchedResultsController.sections?[section] else {
      return 0
    }
    return shortcuts.numberOfObjects
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    guard editingStyle == .delete else {
      return
    }
    let shortcut = fetchedResultsController.object(at: indexPath)
    managedObjectContext.delete(shortcut)
    managedObjectContext.saveContext()
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let section = fetchedResultsController.sections?[section] else {
      return nil
    }
    return section.name
  }
  
}

extension ShortcutsViewController: UITableViewDelegate {
}

extension ShortcutsViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      tableView.insertSections(IndexSet(integer: sectionIndex),
                               with: .automatic)
    case .delete:
      tableView.deleteSections(IndexSet(integer: sectionIndex),
                               with: .none)
    default:
      break
    }
  }
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .automatic)
    case .insert:
      if indexPath != newIndexPath {
        tableView.insertRows(at: [newIndexPath!], with: .automatic)
      }
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}









