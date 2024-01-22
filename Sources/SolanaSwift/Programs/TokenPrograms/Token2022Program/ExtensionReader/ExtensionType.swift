import Foundation

enum ExtensionType: UInt16 {
    /// Used as padding if the account size would otherwise be 355, same as a
    /// multisig
    case Uninitialized
    /// Includes transfer fee rate info and accompanying authorities to withdraw
    /// and set the fee
    case TransferFeeConfig
    /// Includes withheld transfer fees
    case TransferFeeAmount
    /// Includes an optional mint close authority
    case MintCloseAuthority
    /// Auditor configuration for confidential transfers
    case ConfidentialTransferMint
    /// State for confidential transfers
    case ConfidentialTransferAccount
    /// Specifies the default Account::state for new Accounts
    case DefaultAccountState
    /// Indicates that the Account owner authority cannot be changed
    case ImmutableOwner
    /// Require inbound transfers to have memo
    case MemoTransfer
    /// Indicates that the tokens from this mint can't be transfered
    case NonTransferable
    /// Tokens accrue interest over time,
    case InterestBearingConfig
    /// Locks privileged token operations from happening via CPI
    case CpiGuard
    /// Includes an optional permanent delegate
    case PermanentDelegate
    /// Indicates that the tokens in this account belong to a non-transferable
    /// mint
    case NonTransferableAccount
    /// Mint requires a CPI to a program implementing the "transfer hook"
    /// interface
    case TransferHook
    /// Indicates that the tokens in this account belong to a mint with a
    /// transfer hook
    case TransferHookAccount
    /// Includes encrypted withheld fees and the encryption public that they are
    /// encrypted under
    case ConfidentialTransferFeeConfig
    /// Includes confidential withheld transfer fees
    case ConfidentialTransferFeeAmount
    /// Mint contains a pointer to another account (or the same account) that
    /// holds metadata
    case MetadataPointer
    /// Mint contains token-metadata
    case TokenMetadata
    /// Mint contains a pointer to another account (or the same account) that
    /// holds group configurations
    case GroupPointer
    /// Mint contains token group configurations
    case TokenGroup
    /// Mint contains a pointer to another account (or the same account) that
    /// holds group member configurations
    case GroupMemberPointer
    /// Mint contains token group member configurations
    case TokenGroupMember

    // MARK: - Test only

//    /// Test variable-length mint extension
//    case VariableLenMintTest = UInt16.max - 2,
//    /// Padding extension used to make an account exactly Multisig::LEN, used
//    /// for testing
//    case AccountPaddingTest = UInt16.max - 1
//    /// Padding extension used to make a mint exactly Multisig::LEN, used for
//    /// testing
//    case MintPaddingTest = UInt16.max
}
