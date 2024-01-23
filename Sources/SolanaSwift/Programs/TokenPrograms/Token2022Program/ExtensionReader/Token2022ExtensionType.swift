import Foundation

public enum Token2022ExtensionType: UInt16, Codable, Hashable {
    /// Used as padding if the account size would otherwise be 355, same as a
    /// multisig
    case uninitialized
    /// Includes transfer fee rate info and accompanying authorities to withdraw
    /// and set the fee
    case transferFeeConfig
    /// Includes withheld transfer fees
    case transferFeeAmount
    /// Includes an optional mint close authority
    case mintCloseAuthority
    /// Auditor configuration for confidential transfers
    case confidentialTransferMint
    /// State for confidential transfers
    case confidentialTransferAccount
    /// Specifies the default Account::state for new Accounts
    case defaultAccountState
    /// Indicates that the Account owner authority cannot be changed
    case immutableOwner
    /// Require inbound transfers to have memo
    case memoTransfer
    /// Indicates that the tokens from this mint can't be transferred
    case nonTransferable
    /// Tokens accrue interest over time,
    case interestBearingConfig
    /// Locks privileged token operations from happening via CPI
    case cpiGuard
    /// Includes an optional permanent delegate
    case permanentDelegate
    /// Indicates that the tokens in this account belong to a non-transferable
    /// mint
    case nonTransferableAccount
    /// Mint requires a CPI to a program implementing the "transfer hook"
    /// interface
    case transferHook
    /// Indicates that the tokens in this account belong to a mint with a
    /// transfer hook
    case transferHookAccount
    /// Includes encrypted withheld fees and the encryption public that they are
    /// encrypted under
    case confidentialTransferFeeConfig
    /// Includes confidential withheld transfer fees
    case confidentialTransferFeeAmount
    /// Mint contains a pointer to another account (or the same account) that
    /// holds metadata
    case metadataPointer
    /// Mint contains token-metadata
    case tokenMetadata
    /// Mint contains a pointer to another account (or the same account) that
    /// holds group configurations
    case groupPointer
    /// Mint contains token group configurations
    case tokenGroup
    /// Mint contains a pointer to another account (or the same account) that
    /// holds group member configurations
    case groupMemberPointer
    /// Mint contains token group member configurations
    case tokenGroupMember

    // MARK: - Test only

    //    /// Test variable-length mint extension
    //    case variableLenMintTest = UInt16.max - 2,
    //    /// Padding extension used to make an account exactly Multisig::LEN, used
    //    /// for testing
    //    case accountPaddingTest = UInt16.max - 1
    //    /// Padding extension used to make a mint exactly Multisig::LEN, used for
    //    /// testing
    //    case mintPaddingTest = UInt16.max
}
