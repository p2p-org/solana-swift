public struct TokenExtensions: Hashable, Codable {
    public let website: String?
    public let bridgeContract: String?
    public let assetContract: String?
    public let address: String?
    public let explorer: String?
    public let twitter: String?
    public let github: String?
    public let medium: String?
    public let tgann: String?
    public let tggroup: String?
    public let discord: String?
    public let serumV3Usdt: String?
    public let serumV3Usdc: String?
    public let coingeckoId: String?
    public let imageUrl: String?
    public let description: String?

    public init(
        website: String? = nil,
        bridgeContract: String? = nil,
        assetContract: String? = nil,
        address: String? = nil,
        explorer: String? = nil,
        twitter: String? = nil,
        github: String? = nil,
        medium: String? = nil,
        tgann: String? = nil,
        tggroup: String? = nil,
        discord: String? = nil,
        serumV3Usdt: String? = nil,
        serumV3Usdc: String? = nil,
        coingeckoId: String?,
        imageUrl: String? = nil,
        description: String? = nil
    ) {
        self.website = website
        self.bridgeContract = bridgeContract
        self.assetContract = assetContract
        self.address = address
        self.explorer = explorer
        self.twitter = twitter
        self.github = github
        self.medium = medium
        self.tgann = tgann
        self.tggroup = tggroup
        self.discord = discord
        self.serumV3Usdt = serumV3Usdt
        self.serumV3Usdc = serumV3Usdc
        self.coingeckoId = coingeckoId
        self.imageUrl = imageUrl
        self.description = description
    }
}
