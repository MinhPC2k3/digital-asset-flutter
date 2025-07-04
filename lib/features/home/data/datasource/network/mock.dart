var DashboardResponse = '{
  "wallets": [
    {
      "walletId": "wallet_001",
      "walletName": "Main Ethereum Wallet",
      "address": "0xABCDEF1234567890",
      "networkName": "Ethereum",
      "assets": [
        {
          "assetId": "eth_1",
          "symbol": "ETH",
          "balance": "1.2345",
          "decimals": 18,
          "valuationUsd": 3900.23,
          "last24hChange": 2.15
        },
        {
          "assetId": "usdc_1",
          "symbol": "USDC",
          "balance": "5000.00",
          "decimals": 6,
          "valuationUsd": 5000.00,
          "last24hChange": 0.00
        }
      ],
      "nfts": [
        {
          "tokenId": "nft_001",
          "name": "CryptoPunk #123",
          "imageUrl": "https://example.com/images/cryptopunk123.png",
          "collection": "CryptoPunks",
          "estimatedValueUsd": 80000.00
        }
      ]
    },
    {
      "walletId": "wallet_002",
      "walletName": "Polygon Hot Wallet",
      "address": "0x9876FEDCBA123456",
      "networkName": "Polygon",
      "assets": [
        {
          "assetId": "matic_1",
          "symbol": "MATIC",
          "balance": "1500.00",
          "decimals": 18,
          "valuationUsd": 1050.00,
          "last24hChange": -1.87
        }
      ],
      "nfts": []
    }
  ],
  "totalValueUsd": 93950.23
}'