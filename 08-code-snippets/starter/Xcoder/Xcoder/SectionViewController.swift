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

class SectionViewController: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet weak var newSectionTextField: UITextField!
  
  var selectedSection: Section?
  var selectedIndexPath: IndexPath?
  
  var fetchedResultsController: NSFetchedResultsController<Section>?
  var managedObjectContext: NSManagedObjectContext?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let managedObjectContext = managedObjectContext else {
      return
    }
    
    let fetchRequest: NSFetchRequest<Section> = Section.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                          managedObjectContext: managedObjectContext,
                                                          sectionNameKeyPath: nil,
                                                          cacheName: nil)
    fetchedResultsController?.delegate = self
    
    do {
      try fetchedResultsController?.performFetch()
    } catch {
      fatalError("Data Fetch Error")
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let cell = sender as? UITableViewCell {
      if let indexPath = tableView.indexPath(for: cell) {
        selectedSection = fetchedResultsController?.object(at: indexPath)
      }
    }
  }
  
}

// MARK: - Table view data source

extension SectionViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let count = fetchedResultsController?.sections?[0].numberOfObjects {
      return count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    guard let section = fetchedResultsController?.object(at: indexPath) else {
      return cell
    }
    cell.textLabel?.text = section.name
    if let count = section.shortcuts?.count {
      cell.detailTextLabel?.text = "\(count)"
    } else {
      cell.detailTextLabel?.text = nil
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if let section = fetchedResultsController?.object(at: indexPath) {
      if let count = section.shortcuts?.count {
        if count != 0 {
          return false
        }
      }
    }
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    guard editingStyle == .delete else {
      return
    }
    if let section = fetchedResultsController?.object(at: indexPath) {
      managedObjectContext?.delete(section)
      managedObjectContext?.saveContext()
    }
  }
  
  
}

// MARK: - Table view delegate

extension SectionViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndexPath = indexPath
  }
  
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 44))
  }
  
  
}

extension SectionViewController: NSFetchedResultsControllerDelegate {
  
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
                               with: .automatic)
    default:
      break
    }
  }
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
      selectedIndexPath = newIndexPath
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
    default:
      break
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}


extension SectionViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    guard let managedObjectContext = managedObjectContext else {
      return true
    }
    let section = managedObjectContext.insert() as Section
    section.name = textField.text
    managedObjectContext.saveContext()
    
    textField.text = ""
    textField.resignFirstResponder()
    
    return true
  }
  
  
}

