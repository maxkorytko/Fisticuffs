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
import Fisticuffs

class TextFieldSampleViewModel {
    
    let firstName = Observable("")
    let lastName = Observable("")
    let email = Observable("")
    
    
    // Input valid?  (nil signifies no input/indeterminate)
    
    lazy var firstNameValid: Computed<Bool?> = Computed { [firstName = self.firstName] in
        firstName.value.isEmpty ? nil : true
    }
    
    lazy var lastNameValid: Computed<Bool?> = Computed { [lastName = self.lastName] in
        lastName.value.isEmpty ? nil : true
    }
    
    lazy var emailValid: Computed<Bool?> = Computed { [email = self.email] in
        if email.value.isEmpty {
            return nil
        }
        else {
            return email.value.rangeOfString("@") != nil
        }
    }
    
    
    lazy var inputValid: Computed<Bool> = Computed { [weak self] in
        self?.firstNameValid.value == true &&
            self?.lastNameValid.value == true &&
            self?.emailValid.value == true
    }
    
}


class TextFieldSampleViewController: UITableViewController {
    
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var email: UITextField!
    
    @IBOutlet var firstNameValidity: UILabel!
    @IBOutlet var lastNameValidity: UILabel!
    @IBOutlet var emailValidity: UILabel!
    
    //MARK -
    
    let viewModel = TextFieldSampleViewModel()
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstName.b_text <-> viewModel.firstName
        lastName.b_text <-> viewModel.lastName
        email.b_text <-> viewModel.email
        
        
        firstNameValidity.b_text.bind(viewModel.firstNameValid, transform: TextFieldSampleViewController.validStringTransform)
        firstNameValidity.b_textColor.bind(viewModel.firstNameValid, transform: TextFieldSampleViewController.validColorTransform)
        
        lastNameValidity.b_text.bind(viewModel.lastNameValid, transform: TextFieldSampleViewController.validStringTransform)
        lastNameValidity.b_textColor.bind(viewModel.lastNameValid, transform: TextFieldSampleViewController.validColorTransform)
        
        emailValidity.b_text.bind(viewModel.emailValid, transform: TextFieldSampleViewController.validStringTransform)
        emailValidity.b_textColor.bind(viewModel.emailValid, transform: TextFieldSampleViewController.validColorTransform)
        
        // Only let users move on to next field if they've correctly filled out the current one
        firstName.b_shouldReturn.bind(viewModel.firstNameValid, transform: { value in value ?? false })
        lastName.b_shouldReturn.bind(viewModel.lastNameValid, transform: { value in value ?? false })
        email.b_shouldReturn.bind(viewModel.emailValid, transform: { value in value ?? false })
        
        // Pressing enter should move the user on to the next field
        firstName.b_willReturn += { [weak self] in
            self?.lastName.becomeFirstResponder()
        }
        
        lastName.b_willReturn += { [weak self] in
            self?.email.becomeFirstResponder()
        }
        
        email.b_willReturn += { [weak self] in
            self?.email.resignFirstResponder()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        firstName.becomeFirstResponder()
    }
    
    //MARK: -
    
    static func validStringTransform(input: Bool?) -> String {
        switch input {
        case .None: return " "
        case .Some(true): return "✔︎"
        case .Some(false): return "✘"
        }
    }
    
    static func validColorTransform(input: Bool?) -> UIColor {
        switch input {
        case .None: return .blackColor()
        case .Some(true): return UIColor(red: 0.1, green: 0.8, blue: 0.15, alpha: 1.0)
        case .Some(false): return UIColor(red: 0.88, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
}
