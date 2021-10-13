//
//  File.swift
//  
//
//  Created by Chung Tran on 13/10/2021.
//

import Foundation

public extension OrcaSwap {
    struct Aquafarm: Codable {
        let account: String
        let nonce: Int
        let tokenProgramId, emissionsAuthority, removeRewardsAuthority, baseTokenMint: String
        let baseTokenVault, rewardTokenMint, rewardTokenVault, farmTokenMint: String
    }
    
    typealias Aquafarms = [String: Aquafarm] // [poolId: string]: AquafarmJSON;
}
