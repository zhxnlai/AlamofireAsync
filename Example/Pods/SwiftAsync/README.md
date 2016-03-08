# Async

<!-- [![CI Status](http://img.shields.io/travis/Zhixuan Lai/Async.svg?style=flat)](https://travis-ci.org/Zhixuan Lai/Async)
[![Version](https://img.shields.io/cocoapods/v/Async.svg?style=flat)](http://cocoapods.org/pods/Async)
[![License](https://img.shields.io/cocoapods/l/Async.svg?style=flat)](http://cocoapods.org/pods/Async)
[![Platform](https://img.shields.io/cocoapods/p/Async.svg?style=flat)](http://cocoapods.org/pods/Async) -->

Async, await control flow for Swift.

async/await turns this:
~~~swift
// example credit to: http://promisekit.org/chaining
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
    let md5 = md5ForData(data)
    dispatch_async(dispatch_get_main_queue()) {
        self.label.text = md5
        UIView.animateWithDuration(0.3, animations: {
            self.label.alpha = 1
            }) {
            // this is the end point
            // add code to happen next here
        }
    }
}
~~~

into:
~~~swift
async {
    let md5 = md5ForData(data)
    await { async(.Main) { self.label.text = md5 } }
    await { UIView.animateWithDurationAsync(0.3) {self.label.alpha = 1} }
    // this is the end point
    // add code to happen next here
}() {}
~~~

## Installation

Async is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftAsync"
```

## Usage
The example project and [test file](https://github.com/zhxnlai/Async/blob/master/Example/Tests/Tests.swift) will help you get started.

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Prerequisites:
- [Trailing Closures](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Closures.html#//apple_ref/doc/uid/TP40014097-CH11-ID102)
- [GCD](https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/)
- [Capture List](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-ID48)

### async
Here is how you create an async function:
~~~swift
let createImage = async {() -> UIImage in
    sleep(3)
    return UIImage()
}
~~~

Here is how you call an async function, by supplying a callback:
~~~swift
createImage() {image in
  // do something with the image
}
~~~

Here is how you create an async function with parameters:
~~~swift
let fetchImage = {(URL: NSURL) in
    async {() -> UIImage in
        // fetch the image synchronously
        let image = get(URL)
        return image
    }
}

fetchImage(URL)() {image in
    // do something with the image
}
~~~

Let's define more async functions:
~~~swift
let processImage = {(image: UIImage) in
    async {() -> UIImage in
        sleep(1)
        return image
    }
}

let updateImageView = {(image: UIImage) in
    async(.Main) {
        self.imageView.image = image
    }
}
~~~

Instead of chaining async functions with callbacks, use `await`:
~~~swift
print("creating image")
createImage {image in
    print("processing image")
    processImage(image)() {image in
        print("updating imageView")
        updateImageView(image)() {
            print("updated imageView")
        }
    }
}

async {
    print("creating image")
    var image = await { createImage }
    print("processing image")
    image = await { processImage(image) }
    print("updating imageView")
    await { updateImageView(image) }
    print("updated imageView")
}() {}
~~~

### await
`await` is a blocking/synchronous function. Therefore, it should never be called in main thread. It executes an async functions, which is a closure of type `(T -> Void) -> Void`, and returns the result synchronously.

~~~swift
async {
    // blocks the thread until callback is called
    let message = await {(callback: (String -> Void)) in
        sleep(1)
        callback("Hello")
    }
    print(message) // "Hello"
}() {}

// equivalent to
async {
    let message = await {
        async {() -> String in sleep(1); return "Hello" }
    }
    print(message) // "Hello"
}() {}

// equivalent to
async {
    sleep(1)
    let message = "Hello"
    print(message) // "Hello"
} {}
~~~

Here is how to use `await` to wrap asynchronous APIs (eg. network request, animation, ...) and make them synchronous.
~~~swift
let session = NSURLSession(configuration: .ephemeralSessionConfiguration())

let get = {(URL: NSURL) in
    async { () -> (NSData?, NSURLResponse?, NSError?) in
        await {callback in session.dataTaskWithURL(URL, completionHandler: callback).resume()}
    }
}

// with unwrapping
let get2 = {(URL: NSURL) in
    async { () -> (NSData, NSURLResponse)? in
        let (data, response, error) = await {callback in session.dataTaskWithURL(URL, completionHandler: callback).resume()}
        guard let d = data, r = response where error != nil else { return nil }
        return (d, r)
    }
}

async {
  if let (data, response) = await {get2(NSURL())} {
    // do something
  }
}() {}
~~~

~~~swift
extension UIView {
    class func animateWithDurationAsync(duration: NSTimeInterval, animations: () -> Void) -> (Bool -> Void) -> Void {
        return async {
            await {callback in
                async(.Main) {
                    UIView.animateWithDuration(duration, animations: animations, completion: callback)
                }() {}
            }
        }
    }
}

async {
  await { UIView.animateWithDurationAsync(0.3) {self.label.alpha = 1} }
}() {}
~~~

### Serial vs Parallel

To run async functions in series, we can use for/while loops since `await` is blocking/synchronous.
~~~swift
let URLs = [NSURL]()
async {
    var results = [NSData]()
    for URL in URLs {
        results.append(await { get(URL) })
    }
    print("fetched \(results.count) items in series")
}() {}
~~~

To run async functions in parallel, call `await` with an array or a dictionary of async functions.
~~~swift
let URLs = [NSURL]()
async {
    let results = await(parallel: URLs.map(get))
    print("fetched \(results.count) items in parallel")
}() {}
~~~

### Additional APIs
By default, async functions are scheduled in the [global concurrent queue](https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW5) that has [quality of service](https://developer.apple.com/library/ios/documentation/Performance/Conceptual/EnergyGuide-iOS/PrioritizeWorkWithQoS.html) `QOS_CLASS_USER_INITIATED`. To schedule on a different queue:
~~~swift
let taskOnMainThread = async(.Main) {
    // do something
}

let customQueue = dispatch_queue_create("CustomQueueLabel", DISPATCH_QUEUE_CONCURRENT)
let taskOnCustomQueue = async(.Custom(customQueue)) {
    // do something
}
~~~

By default, `await` waits forever for the async function to finish. To add a timeout:
~~~swift
async {
    await(timeout: 0.4) { async { () -> Bool in NSThread.sleepForTimeInterval(0.3); return true } }
}() {value in}
~~~

### Error handling
`async$` and `await$` share the same API with `async` and `await`. In addition, they handle thrown errors:

~~~swift
enum Error: ErrorType {
    case TestError
}

let willThrow = async$ {() throws in
    NSThread.sleepForTimeInterval(0.05)
    throw Error.TestError
}

async$ {
    try await${ willThrow }
}({(_, error) in
    expect(error).to(beTruthy())
})
~~~

### Strong reference cycle
According to [Strong Reference Cycles for Closures](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-ID48)
> A strong reference cycle can also occur if you assign a closure to a property of a class instance, and the body of that closure captures the instance. This capture might occur because the closure’s body accesses a property of the instance, such as self.someProperty, or because the closure calls a method on the instance, such as self.someMethod(). In either case, these accesses cause the closure to “capture” self, creating a strong reference cycle.

It is helpful to add a capture list to the top level closure. Please take a look at the demo project for more examples

~~~swift
async {[weak self] in
    self?.doSomething()
}
~~~

## License

Async is available under the MIT license. See the LICENSE file for more info.
