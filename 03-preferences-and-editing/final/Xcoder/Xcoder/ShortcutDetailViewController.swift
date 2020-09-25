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

class ShortcutDetailViewController: UITableViewController {
  enum State {
    case add, edit
  }
  
  enum Sections: Int {
    case section = 0, shortcut, description, delete
  }
  
  var state: State = .add
  
  var managedObjectContext: NSManagedObjectContext?
  
  @IBOutlet weak var checkbox: Checkbox!
  
  @IBOutlet var accessoryView: UIView!
  
  @IBOutlet weak var keyboardShortcut: UITextField!
  @IBOutlet weak var shortcutDescription: UITextView!
  var section: Section?
  
  @IBOutlet weak var shortcutSection: UILabel!
  @IBOutlet var modifiers: [KeyboardButton]!
  
  var shortcut: Shortcut?
  
  static var lastGroup = "Editing"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    keyboardShortcut.inputAccessoryView = accessoryView
    keyboardShortcut.delegate = self
    
    section = shortcut?.section
    shortcutSection.text = section?.name
    keyboardShortcut.text = shortcut?.keyboardShortcut
    shortcutDescription.text = shortcut?.shortcutDescription
    
  }
  
  // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
      let sections = state == .add ? 3 : 4
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

  @IBAction func keyboardButtonChanged(_ button: KeyboardButton) {
    keyboardShortcut.text?.append(button.modifier)
    button.isEnabled = false
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? SectionViewController {
      destination.managedObjectContext = managedObjectContext
    }
  }
  
  // Unwind from SectionViewController
  // and save section in shortcut
  @IBAction func unwindWithSelectedSection(segue: UIStoryboardSegue) {
    if let controller = segue.source as? SectionViewController {
      section = controller.selectedSection
      shortcutSection.text = section?.name
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == Sections.delete.rawValue {
      guard let shortcut = shortcut else {
        return
      }
      let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
      
      let alertAction = UIAlertAction(title: "Delete Keyboard Shortcut", style: .default) {
        action in
        self.managedObjectContext?.delete(shortcut)
        self.managedObjectContext?.saveContext()
        self.dismiss(animated: true, completion: nil)
      }
      alertAction.setValue(UIColor.red, forKey: "titleTextColor")
      alert.addAction(alertAction)
      
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
      present(alert, animated: true)
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}

// MARK:- UITextFieldDelegate
extension ShortcutDetailViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let text = textField.text {
      for modifierButton in modifiers {
        modifierButton.isEnabled = text.range(of: modifierButton.modifier) == nil
      }
    }
    return true
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    for modifierButton in modifiers {
      modifierButton.isEnabled = true
    }
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    shortcutDescription.becomeFirstResponder()
    return true
  }
  
}


