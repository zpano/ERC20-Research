# ERC20-Research
## 简述
这是我的第一个研究。
主要针对于ERC20代币标准及其可能存在的安全问题。
包括但是不限于历史上存在的安全漏洞。

## ERC20标准
[参考链接1](https://ethereum.org/zh/developers/docs/standards/tokens/erc-20/)

[参考链接2](https://learnblockchain.cn/docs/eips/eip-20.html)

[参考链接3](https://docs.openzeppelin.com/contracts/4.x/erc20)

[代码1](https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20.sol)

[代码2](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20)



## 安全问题
1. [整数溢出](https://github.com/zpano/ERC20-Research/tree/main/整数溢出)
2. [权限控制](https://github.com/zpano/ERC20-Research/tree/main/权限控制)
3. [编码不规范](https://github.com/zpano/ERC20-Research/tree/main/编码不规范)
4. [函数构造](https://github.com/zpano/ERC20-Research/tree/main/函数构造)
5. [加密算法](https://github.com/zpano/ERC20-Research/tree/main/加密算法)

## 自动化审计

## 智能合约爬虫
通过`https://etherscan.com/tokens`获取排名靠前的token，再通过`https://api.etherscan.io/api`获取对应地址的合约源码储存

