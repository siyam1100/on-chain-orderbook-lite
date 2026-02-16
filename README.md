# On-Chain Orderbook Lite

This repository features a minimalist yet powerful Limit Order Book (LOB) engine built with Solidity. Unlike Automated Market Makers (AMMs) like Uniswap, this contract allows for precise price execution through an order-matching system.

## Trading Mechanism


* **Limit Orders:** Users specify the exact price and amount they wish to trade.
* **Storage Optimization:** Uses linked lists or sorted mappings (simplified here) to track orders without excessive gas costs.
* **Atomic Settlement:** Once a match is found, the contract handles the swap of assets between the maker and the taker instantly.

## Features
* **Maker-Taker Model:** Supports both providing liquidity (Maker) and consuming it (Taker).
* **Order Management:** Full lifecycle support including `placeOrder`, `cancelOrder`, and `matchOrders`.
* **Escrow Safety:** Funds are held securely by the contract until a trade is executed or canceled.

## Tech Stack
* **Language:** Solidity 0.8.20
* **Library:** OpenZeppelin (ReentrancyGuard)
