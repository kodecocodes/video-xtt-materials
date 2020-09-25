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
import PDFKit
import CoreData


class PDFViewController: UIViewController {
  @IBOutlet weak var pdfView: PDFView!
  
  // PDF formatting
  fileprivate let margin: CGFloat = 20
  fileprivate let topMargin: CGFloat = 100
  fileprivate let bottomMargin: CGFloat = 60
  fileprivate let lineHeight: CGFloat = 20
  fileprivate let sectionLineHeight: CGFloat = 30
  fileprivate let headerColor = UIColor(red: 0, green: 118/255, blue: 0, alpha: 1)
  fileprivate let PDFSize = CGSize(width: 612, height: 792)
  
  fileprivate var pageNumber:Int = 1
  fileprivate var column: CGFloat = 0
  fileprivate var firstPage = true
  
  fileprivate var documentPath: URL? {
    let fileManager = FileManager.default
    let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
    return documentsUrl.appendingPathComponent("XcoderShortcuts.pdf")
  }
  
  fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Shortcut> = {
    let fetchRequest: NSFetchRequest<Shortcut> = Shortcut.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: Section.sortByNameKey,
                                                     ascending: true)]
    let fetchedResultsController =
      NSFetchedResultsController(fetchRequest: fetchRequest,
                                 managedObjectContext: CoreDataStack.moc,
                                 sectionNameKeyPath: Section.sortByNameKey,
                                 cacheName: nil)
    return fetchedResultsController
  }()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create the pdf
    createPDF()
    
    // Load the pdf file in a UIWebView
    if let url = documentPath {
      pdfView.document = PDFDocument(url: url)
    }
  }
  
  fileprivate func createPDF() {
    // Create PDF
    // set the default page size to 8.5 by 11 inches
    // (612 by 792 points).
    
    guard let pdfPath = documentPath?.path else { return }
    UIGraphicsBeginPDFContextToFile(pdfPath, .zero, nil)
    newPage()
    setupData()
    renderCategories()
    UIGraphicsEndPDFContext()
  }
  
  fileprivate func setupData() {
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Data Fetch Error")
    }
  }
  
  fileprivate func renderCategories() {
    let width = PDFSize.width * 0.5
    let height = PDFSize.height - bottomMargin
    guard let sections = fetchedResultsController.sections else { return }
    var total: CGFloat = topMargin
    let sectionAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16),
                             NSAttributedStringKey.foregroundColor: headerColor]
    let continuedAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14),
                               NSAttributedStringKey.foregroundColor: headerColor]
    let bodyAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 11),
                          NSAttributedStringKey.foregroundColor: UIColor.black]
    for section in sections {
      guard let shortcuts = section.objects as? [Shortcut] else { continue }
      let name = section.name
      
      // new page if not enough room to print item after section header
      if height - total < sectionLineHeight {
        print("render")
        column += 1
        total = topMargin
        if column > 1 {
          newPage()
        }
      }
      var xValue = margin + column * width
      name.draw(at: CGPoint(x: xValue, y: total+5), withAttributes: sectionAttributes)
      total += sectionLineHeight
      for shortcut in shortcuts {
        if total < height {
          shortcut.keyboardShortcut?.draw(at: CGPoint(x: xValue, y: total), withAttributes: bodyAttributes)
          shortcut.shortcutDescription?.draw(at: CGPoint(x: xValue + 100, y: total), withAttributes: bodyAttributes)
          total += lineHeight
        } else {
          column += 1
          total = topMargin
          if column > 1 {
            newPage()
          }
          xValue = margin + column * width
          let text = "\(name) (continued)"
          text.draw(at: CGPoint(x: xValue, y: total+5), withAttributes: continuedAttributes)
          total += sectionLineHeight
          shortcut.keyboardShortcut?.draw(at: CGPoint(x: xValue, y: total), withAttributes: bodyAttributes)
          shortcut.shortcutDescription?.draw(at: CGPoint(x: xValue + 100, y: total), withAttributes: bodyAttributes)
          total += lineHeight
        }
      }
    }
  }
  
  fileprivate func newPage() {
    UIGraphicsBeginPDFPage()
    renderHeader()
    renderFooter()
    renderCenterLine()
    printPageNumber()
    column = 0
  }
  
  fileprivate func renderHeader() {
    guard let logo = UIImage(named: "rw-logo") else { return }
    let rect = CGRect(x: 10, y: 10, width: 70, height: 70)
    logo.draw(in: rect)
    
    let text = "Xcode 9 Cheat Sheet"
    let attributes: [NSAttributedStringKey : NSObject]
    if firstPage {
      attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20),
                    NSAttributedStringKey.foregroundColor: headerColor]
      firstPage = false
    }
    else {
      attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16),
                    NSAttributedStringKey.foregroundColor: headerColor]
    }
    text.draw(at: CGPoint(x: 100, y: 50), withAttributes: attributes)
    
    let context = UIGraphicsGetCurrentContext()
    context?.saveGState()
    context?.setShadow(offset: CGSize(width: 2, height: 2), blur: 5.0)
    let line = UIBezierPath(rect: CGRect(x: 0, y: 0, width: PDFSize.width-20, height: 3))
    let transform = CGAffineTransform(translationX: 10, y: 80)
    line.apply(transform)
    line.fill()
    context?.restoreGState()
  }
  
  fileprivate func renderFooter() {
    let leftText = "Source: raywenderlich.com"
    let rightText = "© 2017 Ray Wenderlich. All rights reserved"
    leftText.draw(at: CGPoint(x: margin, y: PDFSize.height - 20))
    rightText.draw(at: CGPoint(x: PDFSize.width - 250, y: PDFSize.height - 20))
  }
  
  fileprivate func printPageNumber() {
    let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                      NSAttributedStringKey.foregroundColor: UIColor.black]
    let pageNumberString = "Page \(pageNumber)"
    pageNumberString.draw(at: CGPoint(x: PDFSize.width - 60, y: 60), withAttributes: attributes)
    pageNumber += 1
  }
  
  fileprivate func renderCenterLine() {
    let line = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0.5,
                                         height: PDFSize.height - topMargin - bottomMargin + 20))
    let transform = CGAffineTransform(translationX: PDFSize.width/2 , y: topMargin)
    line.apply(transform)
    UIColor.black.setFill()
    line.fill()
  }
  
  @IBAction func showShareSheet(sender: Any) {
    guard let url = documentPath  else { return }
    let activityViewController =
      UIActivityViewController(activityItems: [url],
                               applicationActivities: nil)
    present(activityViewController, animated: true, completion: nil)
  }
}
