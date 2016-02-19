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

import Foundation

public class BidirectionalBindableProperty<Control: AnyObject, ValueType> {
    typealias Getter = Control -> ValueType
    typealias Setter = (Control, ValueType) -> Void

    weak var control: Control?
    let getter: Getter
    let setter: Setter
    let uiChangeEvent: Event<Void> = Event()
    var currentBinding: Disposable?
    
    // Provides an easy way of setting up additional cleanup that should be done
    // after the binding has died (ie, removing UIControl target-actions, deregistering
    // NSNotifications, deregistering KVO notifications)
    var extraCleanup: Disposable?
    
    
    init(control: Control, getter: Getter, setter: Setter, extraCleanup: Disposable? = nil) {
        self.control = control
        self.getter = getter
        self.setter = setter
        self.extraCleanup = extraCleanup
    }
    
    deinit {
        currentBinding?.dispose()
        extraCleanup?.dispose()
    }
}

extension BidirectionalBindableProperty {
    // Should be called when something results in the underlying value being changed
    // (ie., when a user types in a UITextField)
    func pushChangeToObservable() {
        uiChangeEvent.fire()
    }
}

//MARK: - Binding
public extension BidirectionalBindableProperty {
    //MARK: Two way binding
    public func bind(observable: Observable<ValueType>) {
        bind(observable, DefaultBindingHandler())
    }

    public func bind<Data>(observable: Observable<Data>, _ bindingHandler: BindingHandler<Control, Data, ValueType>) {
        currentBinding?.dispose()
        currentBinding = nil

        guard let control = control else { return }

        let disposables = DisposableBag()

        bindingHandler.setup(control, propertySetter: setter, subscribable: observable)
        disposables.add(bindingHandler)

        bindingHandler.setup(getter, changeEvent: uiChangeEvent).subscribe { [weak observable] _, data in
            observable?.value = data
        }.addTo(disposables)

        currentBinding = disposables
    }
    
    //MARK: One way binding

    public func bind(subscribable: Subscribable<ValueType>) {
        bind(subscribable, DefaultBindingHandler())
    }

    public func bind<Data>(subscribable: Subscribable<Data>, _ bindingHandler: BindingHandler<Control, Data, ValueType>) {
        currentBinding?.dispose()
        currentBinding = nil

        guard let control = control else { return }

        bindingHandler.setup(control, propertySetter: setter, subscribable: subscribable)
        currentBinding = bindingHandler
    }
}

//MARK: - Binding - Optionals
public extension BidirectionalBindableProperty where ValueType: OptionalType {
    //MARK: Two way binding

    public func bind(observable: Observable<ValueType.Wrapped>) {
        bind(observable, DefaultBindingHandler())
    }

    public func bind<Data>(observable: Observable<Data>, _ bindingHandler: BindingHandler<Control, Data, ValueType.Wrapped>) {
        currentBinding?.dispose()
        currentBinding = nil

        guard let control = control else { return }

        let disposables = DisposableBag()

        let outerBindingHandler = OptionalTypeBindingHandler<Control, Data, ValueType>(innerHandler: bindingHandler)
        outerBindingHandler.setup(control, propertySetter: setter, subscribable: observable)
        disposables.add(outerBindingHandler)

        outerBindingHandler.setup(getter, changeEvent: uiChangeEvent).subscribe { [weak observable] _, data in
            observable?.value = data
        }.addTo(disposables)

        currentBinding = disposables
    }

    //MARK: One way binding

    public func bind(subscribable: Subscribable<ValueType.Wrapped>) {
        bind(subscribable, DefaultBindingHandler())
    }

    public func bind<Data>(subscribable: Subscribable<Data>, _ bindingHandler: BindingHandler<Control, Data, ValueType.Wrapped>) {
        currentBinding?.dispose()
        currentBinding = nil

        guard let control = control else { return }

        let outerBindingHandler = OptionalTypeBindingHandler<Control, Data, ValueType>(innerHandler: bindingHandler)

        outerBindingHandler.setup(control, propertySetter: setter, subscribable: subscribable)

        currentBinding = outerBindingHandler
    }
}

//MARK: - Deprecated
public extension BidirectionalBindableProperty {
    @available(*, deprecated, message="Use BidirectionBindableProperty(subscribable, BindingHandlers.transform(...)) instead")
    public func bind<OtherType>(subscribable: Subscribable<OtherType>, transform: OtherType -> ValueType) {
        bind(subscribable, BindingHandlers.transform(transform))
    }

    @available(*, deprecated, message="Use a Computed in place of the `block`")
    public func bind(block: () -> ValueType) {
        currentBinding?.dispose()
        currentBinding = nil

        guard let control = control else { return }

        var computed: Computed<ValueType>? = Computed<ValueType>(block: block)

        let bindingHandler = DefaultBindingHandler<Control, ValueType>()
        bindingHandler.setup(control, propertySetter: setter, subscribable: computed!)

        currentBinding = DisposableBlock {
            computed = nil // keep a strong reference to the Computed
            bindingHandler.dispose()
        }
    }
}