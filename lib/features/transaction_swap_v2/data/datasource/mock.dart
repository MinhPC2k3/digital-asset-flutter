var getUserWallet = '''
{
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
          "estimatedValueUsd": 80000.00,
          "asset_id": "asset-nft-token-lcp-0001"
        }
      ],
      "totalValueUsd": 88900.23
    },
    {
      "walletId": "wallet_002",
      "walletName": "Binance Hot Wallet",
      "address": "0x9876FEDCBA123456",
      "networkName": "Binance",
      "assets": [
        {
          "assetId": "bnb_01",
          "symbol": "BNB",
          "balance": "1500.00",
          "decimals": 18,
          "valuationUsd": 1050.00,
          "last24hChange": -1.87
        }
      ],
      "nfts": [],
      "totalValueUsd": 1050.00
    }
  ]
}
''';
var getSwapQuote = '''
{
  "quote": {
    "quote_id": "quote_abc123",
    "deposit_address": "0xabc123def456...",
    "estimated_fee": "0.00",
    "rate": 2998.75,
    "status": "quote_generated",
    "expiration_time": 1720359200,
    "send_amount": "1.5",
    "receive_amount": "4498.125"
  }
}
''';

var getListAssetResponse = '''
{
  "assets": [
    {
      "assetId": "eth_1",
      "symbol": "ETH",
      "balance": "0",
      "decimals": 18,
      "valuationUsd": 0,
      "last24hChange": 0,
      "networkName": "ethereum"
    },
    {
      "assetId": "usdc_1",
      "symbol": "USDC",
      "balance": "0",
      "decimals": 6,
      "valuationUsd": 0,
      "last24hChange": 0,
      "networkName": "ethereum"
    },
    {
      "assetId": "bnb_1",
      "symbol": "BNB",
      "balance": "0",
      "decimals": 18,
      "valuationUsd": 0,
      "last24hChange": 0,
      "networkName": "binance"
    },
    {
      "assetId": "matic_1",
      "symbol": "MATIC",
      "balance": "0",
      "decimals": 18,
      "valuationUsd": 0,
      "last24hChange": 0,
      "networkName": "polygon"
    }
  ]
}
''';
