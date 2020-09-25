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

protocol CheckboxDelegate {
func checkBox(checkBox: Checkbox, userChecked: Filter)
}

class Checkbox: UIView {
  
var checked: Filter = .none {
didSet {
updateAppearance()
}
}
  
var checkmarkImageView: UIImageView!
var delegate: CheckboxDelegate?
  
required init?(coder aDecoder: NSCoder) {
super.init(coder: aDecoder)
commonInit()
updateAppearance()
}
  
func commonInit() {
checkmarkImageView = UIImageView(image: UIImage(asset: .checkmark))
checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
self.addSubview(checkmarkImageView)
checkmarkImageView.isHidden = true

    
checkmarkImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
layer.borderWidth = 2.0
layer.cornerRadius = 6.0
}
  
func updateAppearance() {
let primaryColor: UIColor
let borderColor: UIColor
let backgroundColor: UIColor
    
switch checked {
case .none:
primaryColor = .white
borderColor = UIColor(asset: .uncheckedBorder)
backgroundColor = .white
checkmarkImageView.isHidden = true
case .done:
primaryColor = UIColor(asset: .checkedPrimary)
borderColor = UIColor(asset: .checkedBorder)
backgroundColor = UIColor(asset: .checkedBackground)
checkmarkImageView.isHidden = false
case .hide:
primaryColor = UIColor(asset: .hidePrimary)
borderColor = UIColor(asset: .hideBorder)
backgroundColor = UIColor(asset: .hideBackground)
checkmarkImageView.isHidden = false
}
    
checkmarkImageView.tintColor = primaryColor
self.backgroundColor = backgroundColor
layer.borderColor = borderColor.cgColor
}
  
func updateChecked(oldValue: Filter) -> Filter {
var newValue = oldValue.rawValue + 1
if newValue > 2 {
newValue = 0
}
guard let filter = Filter(rawValue: newValue) else {
fatalError("Incorrect checkmark value")
}
return filter
}
  
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
checked = updateChecked(oldValue: checked)
delegate?.checkBox(checkBox: self,
userChecked: checked)
}
  
override var intrinsicContentSize : CGSize {
return CGSize(width: 30.0, height: 30.0)
}

}


