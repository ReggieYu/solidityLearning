// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

//ERC20 代币
//任务：参考 openzeppelin-contracts/contracts/token/ERC20/IERC20.sol实现一个简单的 ERC20 代币合约。要求：
//合约包含以下标准 ERC20 功能：
//balanceOf：查询账户余额。
//transfer：转账。
//approve 和 transferFrom：授权和代扣转账。
//使用 event 记录转账和授权操作。
//提供 mint 函数，允许合约所有者增发代币。
//提示：
//使用 mapping 存储账户余额和授权信息。
//使用 event 定义 Transfer 和 Approval 事件。
//部署到sepolia 测试网，导入到自己的钱包

contract MyToken is Ownable {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    // 余额映射: address => balance
    mapping(address => uint256) private _balances;
    // 授权映射：(owner => (spender => amount))
    mapping(address => mapping(address => uint256)) private _allowances;

    // event
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // 构造函数：初始化所有者
    constructor() Ownable(msg.sender) {}

    // 查询余额
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // 转账
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "transfer to zero address");
        require(_balances[msg.sender] >= amount, "insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // 授权
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 代扣转账
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(to != address(0), " transfer to zero address");
        require(_balances[from] >= amount, "insufficient balance");
        require(
            _allowances[from][msg.sender] >= amount,
            "insufficient allowance"
        );
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    // 增发代币(仅所有者可以调用)
    function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), " transfer to zero address");
        _balances[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }
}
