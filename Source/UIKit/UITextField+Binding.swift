//  The MIT License (MIT)
//
//  Copyright (c) 2015 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit


public extension UITextField {
    
    var b_text: BidirectionalBinding<String> {
        get {
            return get("b_text", orSet: {
                addTarget(self, action: "b_valueChanged:", forControlEvents: .EditingChanged)
                let cleanup = DisposableBlock { [weak self] in
                    self?.removeTarget(self, action: "b_valueChanged:", forControlEvents: .EditingChanged)
                }
                
                return BidirectionalBinding<String>(
                    getter: { [weak self] in self?.text ?? "" },
                    setter: { [weak self] value in self?.text = value },
                    extraCleanup: cleanup
                )
            })
        }
    }
    
    @objc private func b_valueChanged(sender: UITextField) {
        b_text.pushChangeToObservable()
    }
    
    
    var b_didBeginEditing: Event<UIEvent?> {
        return b_controlEvent(.EditingDidBegin)
    }
    
    var b_didEndEditing: Event<UIEvent?> {
        return b_controlEvent([.EditingDidEnd, .EditingDidEndOnExit])
    }
    
}


public extension UITextField {

    private var b_delegate: TextFieldDelegate {
        return get("b_delegate", orSet: {
            let delegate = TextFieldDelegate()
            self.delegate = delegate
            return delegate
        })
    }
    
    var b_shouldBeginEditing: Binding<Bool> {
        return get("b_shouldBeginEditing", orSet: {
            let delegate = b_delegate
            return Binding { value in
                delegate.shouldBeginEditing = value
            }
        })
    }
    
    var b_shouldEndEditing: Binding<Bool> {
        return get("b_shouldEndEditing", orSet: {
            let delegate = b_delegate
            return Binding { value in
                delegate.shouldEndEditing = value
            }
        })
    }
    
    var b_shouldClear: Binding<Bool> {
        return get("b_shouldClear", orSet: {
            let delegate = b_delegate
            return Binding { value in
                delegate.shouldClear = value
            }
        })
    }
    
    var b_shouldReturn: Binding<Bool> {
        return get("b_shouldReturn", orSet: {
            let delegate = b_delegate
            return Binding { value in
                delegate.shouldReturn = value
            }
        })
    }
    
    var b_willClear: Event<Void> {
        return b_delegate.willClear
    }
    
    var b_willReturn: Event<Void> {
        return b_delegate.willReturn
    }

}

private class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    let willClear = Event<Void>()
    let willReturn = Event<Void>()
    
    var shouldBeginEditing = true
    var shouldEndEditing = true
    
    var shouldClear = true
    var shouldReturn = true
    
    @objc func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return shouldBeginEditing
    }
    
    @objc func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return shouldEndEditing
    }
    
    @objc func textFieldShouldClear(textField: UITextField) -> Bool {
        let retVal = shouldClear // copy to guard against `shouldClear` being changed in any event subscriptions
        if retVal {
            willClear.fire()
        }
        return retVal
    }
    
    @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
        let retVal = shouldReturn // copy to guard against `shouldReturn` being changed in any event subscriptions
        if retVal {
            willReturn.fire()
        }
        return retVal
    }
    
}
