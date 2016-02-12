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


public class BindingHandler<Control: AnyObject, DataValue, PropertyValue>: Disposable {
    public typealias PropertySetter = (Control, PropertyValue) -> Void

    private weak var control: Control?
    private var propertySetter: PropertySetter?

    private let disposableBag = DisposableBag()

    func setup(control: Control, propertySetter: PropertySetter, subscribable: Subscribable<DataValue>) {
        self.control = control
        self.propertySetter = propertySetter

        subscribable.subscribe { [weak self] oldValue, newValue in
            if let this = self, control = this.control, propertySetter = this.propertySetter {
                this.set(control: control, oldValue: oldValue, value: newValue, propertySetter: propertySetter)
            }
        }
        .addTo(disposableBag)
    }

    public func set(control control: Control, oldValue: DataValue?, value: DataValue, propertySetter: PropertySetter) {
        // Override in subclasses
    }

    public func dispose() {
        disposableBag.dispose()
    }
}
