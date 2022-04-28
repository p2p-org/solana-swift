import Foundation

protocol AccountStorageType: AnyObject {
    func getAccount() -> Account?
    func save(_ account: Account) throws
}
