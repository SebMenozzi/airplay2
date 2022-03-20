import Foundation

infix operator .. : MultiplicationPrecedence

/**
Custom operator that calls the specified block `self` value as its argument and returns `self`.

 ```
 let label = UILabel()..{
    $0.textColor = .black
    $0.numberOfLines = 1
 }
 ```
*/
@discardableResult
public func .. <T>(object: T, block: (inout T) -> Void) -> T {
    var object = object
    block(&object)
    return object
}
