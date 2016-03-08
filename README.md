# AlamofireAsync
Async extension for [Alamofire](https://github.com/Alamofire/Alamofire)

<!--
[![CI Status](http://img.shields.io/travis/Zhixuan Lai/AlamofireAsync.svg?style=flat)](https://travis-ci.org/Zhixuan Lai/AlamofireAsync)
[![Version](https://img.shields.io/cocoapods/v/AlamofireAsync.svg?style=flat)](http://cocoapods.org/pods/AlamofireAsync)
[![License](https://img.shields.io/cocoapods/l/AlamofireAsync.svg?style=flat)](http://cocoapods.org/pods/AlamofireAsync)
[![Platform](https://img.shields.io/cocoapods/p/AlamofireAsync.svg?style=flat)](http://cocoapods.org/pods/AlamofireAsync)
-->

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

~~~swift
import Alamofire
import AlamofireAsync
import SwiftAsync

async {
    let request = Alamofire.request(.GET, "https://httpbin.org/get")
    let response = await { request.responseJSONAsync() }

    print(response.request)  // original URL request
    print(response.response) // URL response
    print(response.data)     // server data
    print(response.result)   // result of response serialization

    if let JSON = response.result.value {
        print("JSON: \(JSON)")
    }
} () {}
~~~

## Installation

AlamofireAsync is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AlamofireAsync"
```

## Author

Zhixuan Lai, zhxnlai@gmail.com

## License

AlamofireAsync is available under the MIT license. See the LICENSE file for more info.
