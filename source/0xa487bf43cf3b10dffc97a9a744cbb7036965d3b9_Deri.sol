{{
  "language": "Solidity",
  "sources": {
    "contracts/Deri.sol": {
      "content": "// SPDX-License-Identifier: MITr
r
pragma solidity >=0.6.2 <0.8.0;r
r
import "./SafeMath.sol";r
r
r
contract Deri {r
r
    using SafeMath for uint256;r
r
    event ChangeController(address oldController, address newController);r
r
    event Approval(address indexed owner, address indexed spender, uint256 amount);r
r
    event Transfer(address indexed from, address indexed to, uint256 amount);r
r
    string public constant name = "Deri";r
r
    string public constant symbol = "DERI";r
r
    uint8 public constant decimals = 18;r
r
    uint256 public maxSupply = 1_000_000_000e18; // 1 billionr
r
    uint256 public totalSupply;r
r
    address public controller;r
r
    mapping (address => uint256) internal balances;r
r
    mapping (address => mapping (address => uint256)) internal allowances;r
r
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");r
r
    bytes32 public constant MINT_TYPEHASH = keccak256("Mint(address account,uint256 amount,uint256 nonce,uint256 deadline)");r
r
    mapping (address => uint256) public nonces;r
r
    constructor (address treasury) {r
        uint256 treasuryAmount = 400_000_000e18; // 40% DERI into treasuryr
        totalSupply = treasuryAmount;r
        balances[treasury] = treasuryAmount;r
        emit Transfer(address(0), treasury, treasuryAmount);r
r
        controller = msg.sender;r
        emit ChangeController(address(0), controller);r
    }r
r
    // In order to prevent setting controller to an incorrect newController and forever lost the controll of this contract,r
    // a signature of message keccak256(bytes(name)) from the newController must be provided.r
    function setController(address newController, uint8 v, bytes32 r, bytes32 s) public {r
        require(msg.sender == controller, "Deri.setController: only controller can set controller");r
        require(v == 27 || v == 28, "Deri.setController: v not valid");r
        bytes32 message = keccak256(bytes(name));r
        bytes32 hash = keccak256(abi.encodePacked("x19Ethereum Signed Message:
32", message));r
        address signatory = ecrecover(hash, v, r, s);r
        require(signatory == newController, "Deri.setController: newController is not the signatory");r
r
        emit ChangeController(controller, newController);r
        controller = newController;r
    }r
r
    function balanceOf(address account) public view returns (uint256) {r
        return balances[account];r
    }r
r
    function allowance(address owner, address spender) public view returns (uint256) {r
        return allowances[owner][spender];r
    }r
r
    function approve(address spender, uint256 amount) public returns (bool) {r
        require(spender != address(0), "Deri.approve: approve to zero address");r
        allowances[msg.sender][spender] = amount;r
        emit Approval(msg.sender, spender, amount);r
        return true;r
    }r
r
    function transfer(address to, uint256 amount) public returns (bool) {r
        require(to != address(0), "Deri.transfer: transfer to zero address");r
        _transfer(msg.sender, to, amount);r
        return true;r
    }r
r
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {r
        require(to != address(0), "Deri.transferFrom: transfer to zero address");r
r
        uint256 oldAllowance = allowances[from][msg.sender];r
        if (msg.sender != from && oldAllowance != uint256(-1)) {r
            uint256 newAllowance = oldAllowance.sub(amount, "Deri.transferFrom: amount exceeds allowance");r
            allowances[from][msg.sender] = newAllowance;r
            emit Approval(from, msg.sender, newAllowance);r
        }r
r
        _transfer(from, to, amount);r
        return true;r
    }r
r
    function mint(address account, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {r
        require(block.timestamp <= deadline, "Deri.mint: signature expired");r
r
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), _getChainId(), address(this)));r
        bytes32 structHash = keccak256(abi.encode(MINT_TYPEHASH, account, amount, nonces[account]++, deadline));r
        bytes32 digest = keccak256(abi.encodePacked("x19x01", domainSeparator, structHash));r
        address signatory = ecrecover(digest, v, r, s);r
        require(signatory == controller, "Deri.mint: unauthorized");r
r
        balances[account] = balances[account].add(amount);r
        totalSupply = totalSupply.add(amount);r
r
        require(totalSupply <= maxSupply, "Deri.mint: totalSupply exceeds maxSupply");r
        emit Transfer(address(0), account, amount);r
    }r
r
    function _transfer(address from, address to, uint256 amount) internal {r
        balances[from] = balances[from].sub(amount, "Deri._transfer: amount exceeds balance");r
        balances[to] = balances[to].add(amount, "Deri._transfer: amount overflows");r
        emit Transfer(from, to, amount);r
    }r
r
    function _getChainId() internal pure returns (uint256) {r
        uint256 chainId;r
        assembly {r
            chainId := chainid()r
        }r
        return chainId;r
    }r
r
}r
"
    },
    "contracts/SafeMath.sol": {
      "content": "// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(a, b, "SafeMath: addition overflow");
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return mul(a, b, "SafeMath: multiplication overflow");
    }

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    },
    "libraries": {}
  }
}}