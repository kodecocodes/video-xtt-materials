
///**
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

import CoreData
import Checkbox



// MARK:- Data Seed Import

extension CoreDataStack {
  class func seedData(managedContext: NSManagedObjectContext) {
    print("Initializing data...")
    guard let seedFile = Bundle.main.path(forResource: "DataSeed", ofType: "json")
      else { return }
    
    struct SeedData: Codable {
      struct Section: Codable {
        let name: String
        struct Shortcut: Codable {
          let keyboardShortcut: String
          let shortcutDescription: String
          let filter: Int16?
        }
        let shortcuts: [Shortcut]
      }
      let sections: [Section]
    }
    
    do {
      let jsonData = try Data(contentsOf: URL(fileURLWithPath: seedFile))
      let decoder = JSONDecoder()
      let seedData = try decoder.decode(SeedData.self, from: jsonData)
      for section in seedData.sections {
        
        let newSection = managedContext.insert() as Section
        
        newSection.name = section.name
        
        for shortcut in section.shortcuts {
          let newShortcut = managedContext.insert() as Shortcut
          
          newShortcut.section = newSection
          newShortcut.keyboardShortcut = shortcut.keyboardShortcut
          newShortcut.shortcutDescription = shortcut.shortcutDescription
          if let filter = shortcut.filter {
            newShortcut.filter = Filter(rawValue: filter) ?? .none
          } else {
            newShortcut.filter = .none
          }
        }
      }
      try managedContext.save()
    } catch let error as NSError {
      fatalError(error.localizedDescription)
    }
  }
  
  
}


