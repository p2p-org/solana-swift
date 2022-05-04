import Foundation

protocol AccountStorage: AnyObject {
    var account: Account? {get throws}
    func save(_ account: Account) throws
}
