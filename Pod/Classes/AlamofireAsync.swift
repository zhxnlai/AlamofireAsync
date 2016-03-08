import Alamofire
import SwiftAsync

extension Request {

    // MARK: - Default
    public func responseAsync<T: ResponseSerializerType>(
        queue queue: dispatch_queue_t? = nil,
        responseSerializer: T)
        -> (Response<T.SerializedObject, T.ErrorObject> -> Void) -> Void {
        return async { await {completionHandler in self.response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)}}
    }

    // MARK: - Data
    public func responseDataAsync() -> (Response<NSData, NSError> -> Void) -> Void {
        return async { await {completionHandler in self.responseData(completionHandler)}}
    }

    // MARK: - String
    public func responseStringAsync(
        encoding encoding: NSStringEncoding? = nil)
        -> (Response<String, NSError> -> Void) -> Void {
        return async { await {completionHandler in self.responseString(encoding: encoding, completionHandler: completionHandler)}}
    }

    // MARK: - JSON
    public func responseJSONAsync(
        options options: NSJSONReadingOptions = .AllowFragments)
        -> (Response<AnyObject, NSError> -> Void) -> Void {
        return async { await {completionHandler in self.responseJSON(options: options, completionHandler: completionHandler)}}
    }


    // MARK: - Property List
    public func responsePropertyListAsync(
        options options: NSPropertyListReadOptions = NSPropertyListReadOptions())
        -> (Response<AnyObject, NSError> -> Void) -> Void {
            return async { await {completionHandler in self.responsePropertyList(options: options, completionHandler: completionHandler)}}
    }

}
