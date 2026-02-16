// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Orderbook is ReentrancyGuard {
    enum Side { Buy, Sell }

    struct Order {
        uint256 id;
        address trader;
        Side side;
        uint256 amount;
        uint256 price;
    }

    IERC20 public baseToken; // e.g., WETH
    IERC20 public quoteToken; // e.g., USDC
    uint256 public nextOrderId;
    mapping(uint256 => Order) public orders;

    event OrderPlaced(uint256 indexed id, address indexed trader, Side side, uint256 amount, uint256 price);
    event OrderCanceled(uint256 indexed id);
    event TradeExecuted(uint256 buyOrderId, uint256 sellOrderId, uint256 amount, uint256 price);

    constructor(address _baseToken, address _quoteToken) {
        baseToken = IERC20(_baseToken);
        quoteToken = IERC20(_quoteToken);
    }

    function placeOrder(Side _side, uint256 _amount, uint256 _price) external nonReentrant {
        require(_amount > 0 && _price > 0, "Invalid order parameters");

        if (_side == Side.Buy) {
            quoteToken.transferFrom(msg.sender, address(this), _amount * _price);
        } else {
            baseToken.transferFrom(msg.sender, address(this), _amount);
        }

        orders[nextOrderId] = Order(nextOrderId, msg.sender, _side, _amount, _price);
        emit OrderPlaced(nextOrderId, msg.sender, _side, _amount, _price);
        nextOrderId++;
    }

    function cancelOrder(uint256 _orderId) external nonReentrant {
        Order storage order = orders[_orderId];
        require(order.trader == msg.sender, "Not your order");
        require(order.amount > 0, "Order already filled or canceled");

        uint256 refundAmount = order.amount;
        order.amount = 0;

        if (order.side == Side.Buy) {
            quoteToken.transfer(msg.sender, refundAmount * order.price);
        } else {
            baseToken.transfer(msg.sender, refundAmount);
        }

        emit OrderCanceled(_orderId);
    }

    function matchOrders(uint256 _buyOrderId, uint256 _sellOrderId) external nonReentrant {
        Order storage buyOrder = orders[_buyOrderId];
        Order storage sellOrder = orders[_sellOrderId];

        require(buyOrder.side == Side.Buy && sellOrder.side == Side.Sell, "Invalid sides");
        require(buyOrder.price >= sellOrder.price, "Price mismatch");
        require(buyOrder.amount > 0 && sellOrder.amount > 0, "Order empty");

        uint256 fillAmount = buyOrder.amount < sellOrder.amount ? buyOrder.amount : sellOrder.amount;

        buyOrder.amount -= fillAmount;
        sellOrder.amount -= fillAmount;

        // Settlement
        baseToken.transfer(buyOrder.trader, fillAmount);
        quoteToken.transfer(sellOrder.trader, fillAmount * sellOrder.price);

        emit TradeExecuted(_buyOrderId, _sellOrderId, fillAmount, sellOrder.price);
    }
}
