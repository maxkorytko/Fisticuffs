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

class TableViewSampleViewModel {
    let items = Observable([1, 2, 3, 4, 5, 6, 7, 8, 9])
    
    let editing = Observable(false)
    lazy var editingButtonTitle: Computed<String> = Computed { [editing = self.editing] in
        editing.value ? "Done" : "Edit"
    }
    
    func toggleEditing() {
        editing.value = !editing.value
    }
    
    
    func prependItem() {
        if let min = items.value.minElement() {
            items.value.insert(min - 1, atIndex: 0)
        }
        else {
            items.value.insert(1, atIndex: 0)
        }
    }
    
    func appendItem() {
        if let max = items.value.maxElement() {
            items.value.append(max + 1)
        }
        else {
            items.value.append(1)
        }
    }
}


class TableViewSampleController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var prependButton: UIBarButtonItem!
    @IBOutlet var appendButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    
    //MARK: -
    
    let viewModel = TableViewSampleViewModel()
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.b_configure(viewModel.items) { config in
            config.allowsMoving = true
            config.allowsDeletion = true
            config.useCell(reuseIdentifier: "Cell") { item, cell in
                cell.textLabel?.text = "\(item)"
            }
        }
        tableView.b_editing <-- viewModel.editing
        
        editButton.b_onTap += viewModel.toggleEditing
        editButton.b_title <-- viewModel.editingButtonTitle
        
        prependButton.b_onTap += viewModel.prependItem
        appendButton.b_onTap += viewModel.appendItem
    }
    
}
