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
import Quick
import Nimble
@testable import Fisticuffs


class ComputedSpec: QuickSpec {
    override func spec() {
        describe("Computed") {
            it("should derive its value from the provided block") {
                let a = Observable(11)
                let b = Observable(42)
                
                let sum = Computed { a.value + b.value }
                expect(sum.value) == 53
            }
            
            it("should update its value when any dependencies change") {
                let a = Observable(11)
                let b = Observable(42)
                
                let sum = Computed { a.value + b.value }
                
                a.value = 42
                expect(sum.value) == 84
            }
            
            it("should allow for Observable and Computed dependencies") {
                let a = Observable(11)
                let b = Observable(42)
                
                let sum = Computed { a.value + b.value }
                let display = Computed { "Sum: \(sum.value)" }
                
                a.value = 42
                expect(display.value) == "Sum: 84"
            }
        }
    }
}
