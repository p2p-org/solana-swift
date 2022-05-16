import Foundation

public enum SocketMethod: String {
    case accountNotification
    case accountSubscribe
    case accountUnsubscribe

    case signatureNotification
    case signatureSubscribe
    case signatureUnsubscribe

    case logsSubscribe
    case logsNotification
    case logsUnsubscribe

    case programSubscribe
    case programNotification
    case programUnsubscribe

    case slotSubscribe
    case slotNotification
    case slotUnsubscribe
}
