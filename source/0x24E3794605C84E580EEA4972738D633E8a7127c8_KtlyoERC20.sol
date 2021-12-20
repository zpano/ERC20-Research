{"Context.sol":{"content":"// SPDX-License-Identifier: MITr
r
pragma solidity ^0.6.0;r
r
/*r
 * @dev Provides information about the current execution context, including ther
 * sender of the transaction and its data. While these are generally availabler
 * via msg.sender and msg.data, they should not be accessed in such a directr
 * manner, since when dealing with GSN meta-transactions the account sending andr
 * paying for execution may not be the actual sender (as far as an applicationr
 * is concerned).r
 *r
 * This contract is only required for intermediate, library-like contracts.r
 */r
abstract contract Context {r
    function _msgSender() internal view virtual returns (address payable) {r
        return msg.sender;r
    }r
r
    function _msgData() internal view virtual returns (bytes memory) {r
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691r
        return msg.data;r
    }r
}"},"ERC20.sol":{"content":"// SPDX-License-Identifier: MITr
r
pragma solidity ^0.6.0;r
r
import "Context.sol";r
import "IERC20.sol";r
import "SafeMath.sol";r
r
/**r
 * @dev Implementation of the {IERC20} interface.r
 *r
 * This implementation is agnostic to the way tokens are created. This meansr
 * that a supply mechanism has to be added in a derived contract using {_mint}.r
 * For a generic mechanism see {ERC20PresetMinterPauser}.r
 *r
 * TIP: For a detailed writeup see our guider
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[Howr
 * to implement supply mechanisms].r
 *r
 * We have followed general OpenZeppelin guidelines: functions revert insteadr
 * of returning `false` on failure. This behavior is nonetheless conventionalr
 * and does not conflict with the expectations of ERC20 applications.r
 *r
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.r
 * This allows applications to reconstruct the allowance for all accounts justr
 * by listening to said events. Other implementations of the EIP may not emitr
 * these events, as it isnu0027t required by the specification.r
 *r
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}r
 * functions have been added to mitigate the well-known issues around settingr
 * allowances. See {IERC20-approve}.r
 */r
contract ERC20 is Context, IERC20 {r
    using SafeMath for uint256;r
r
    mapping (address =u003e uint256) private _balances;r
r
    mapping (address =u003e mapping (address =u003e uint256)) private _allowances;r
r
    uint256 private _totalSupply;r
r
    string private _name;r
    string private _symbol;r
    uint8 private _decimals;r
    uint256 private _cap;r
    /**r
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} withr
     * a default value of 18.r
     *r
     * To select a different value for {decimals}, use {_setupDecimals}.r
     *r
     * All three of these values are immutable: they can only be set once duringr
     * construction.r
     */r
    constructor (string memory name, string memory symbol) public {r
        _name = name;r
        _symbol = symbol;r
        _decimals = 18;r
        _cap = 85000000 * 10**uint(18);r
    }r
r
    /**r
     * @dev Returns the name of the token.r
     */r
    function name() public view returns (string memory) {r
        return _name;r
    }r
r
    /**r
     * @dev Returns the symbol of the token, usually a shorter version of ther
     * name.r
     */r
    function symbol() public view returns (string memory) {r
        return _symbol;r
    }r
r
    /**r
     * @dev Returns the number of decimals used to get its user representation.r
     * For example, if `decimals` equals `2`, a balance of `505` tokens shouldr
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).r
     *r
     * Tokens usually opt for a value of 18, imitating the relationship betweenr
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} isr
     * called.r
     *r
     * NOTE: This information is only used for _display_ purposes: it inr
     * no way affects any of the arithmetic of the contract, includingr
     * {IERC20-balanceOf} and {IERC20-transfer}.r
     */r
    function decimals() public view returns (uint8) {r
        return _decimals;r
    }r
r
    /**r
     * @dev See {IERC20-totalSupply}.r
     */r
    function totalSupply() public view override returns (uint256) {r
        return _totalSupply;r
    }r
r
    /**r
     * @dev See {IERC20-balanceOf}.r
     */r
    function balanceOf(address account) public view override returns (uint256) {r
        return _balances[account];r
    }r
r
    /**r
     * @dev See {IERC20-transfer}.r
     *r
     * Requirements:r
     *r
     * - `recipient` cannot be the zero address.r
     * - the caller must have a balance of at least `amount`.r
     */r
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {r
        _transfer(_msgSender(), recipient, amount);r
        return true;r
    }r
r
    /**r
     * @dev See {IERC20-allowance}.r
     */r
    function allowance(address owner, address spender) public view virtual override returns (uint256) {r
        return _allowances[owner][spender];r
    }r
r
    /**r
     * @dev See {IERC20-approve}.r
     *r
     * Requirements:r
     *r
     * - `spender` cannot be the zero address.r
     */r
    function approve(address spender, uint256 amount) public virtual override returns (bool) {r
        _approve(_msgSender(), spender, amount);r
        return true;r
    }r
r
    /**r
     * @dev See {IERC20-transferFrom}.r
     *r
     * Emits an {Approval} event indicating the updated allowance. This is notr
     * required by the EIP. See the note at the beginning of {ERC20}.r
     *r
     * Requirements:r
     *r
     * - `sender` and `recipient` cannot be the zero address.r
     * - `sender` must have a balance of at least `amount`.r
     * - the caller must have allowance for ``sender``u0027s tokens of at leastr
     * `amount`.r
     */r
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {r
        _transfer(sender, recipient, amount);r
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));r
        return true;r
    }r
r
    /**r
     * @dev Atomically increases the allowance granted to `spender` by the caller.r
     *r
     * This is an alternative to {approve} that can be used as a mitigation forr
     * problems described in {IERC20-approve}.r
     *r
     * Emits an {Approval} event indicating the updated allowance.r
     *r
     * Requirements:r
     *r
     * - `spender` cannot be the zero address.r
     */r
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {r
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));r
        return true;r
    }r
r
    /**r
     * @dev Atomically decreases the allowance granted to `spender` by the caller.r
     *r
     * This is an alternative to {approve} that can be used as a mitigation forr
     * problems described in {IERC20-approve}.r
     *r
     * Emits an {Approval} event indicating the updated allowance.r
     *r
     * Requirements:r
     *r
     * - `spender` cannot be the zero address.r
     * - `spender` must have allowance for the caller of at leastr
     * `subtractedValue`.r
     */r
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {r
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));r
        return true;r
    }r
r
    /**r
     * @dev Moves tokens `amount` from `sender` to `recipient`.r
     *r
     * This is internal function is equivalent to {transfer}, and can be used tor
     * e.g. implement automatic token fees, slashing mechanisms, etc.r
     *r
     * Emits a {Transfer} event.r
     *r
     * Requirements:r
     *r
     * - `sender` cannot be the zero address.r
     * - `recipient` cannot be the zero address.r
     * - `sender` must have a balance of at least `amount`.r
     */r
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {r
        require(sender != address(0), "ERC20: transfer from the zero address");r
        require(recipient != address(0), "ERC20: transfer to the zero address");r
r
        _beforeTokenTransfer(sender, recipient, amount);r
r
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");r
        _balances[recipient] = _balances[recipient].add(amount);r
        emit Transfer(sender, recipient, amount);r
    }r
r
    /** @dev Creates `amount` tokens and assigns them to `account`, increasingr
     * the total supply.r
     *r
     * Emits a {Transfer} event with `from` set to the zero address.r
     *r
     * Requirements:r
     *r
     * - `to` cannot be the zero address.r
     */r
    function _mint(address account, uint256 amount) internal virtual {r
        require(account != address(0), "ERC20: mint to the zero address");r
r
        _beforeTokenTransfer(address(0), account, amount);r
r
        _totalSupply = _totalSupply.add(amount);r
        _balances[account] = _balances[account].add(amount);r
        emit Transfer(address(0), account, amount);r
    }r
r
    /**r
     * @dev Destroys `amount` tokens from `account`, reducing ther
     * total supply.r
     *r
     * Emits a {Transfer} event with `to` set to the zero address.r
     *r
     * Requirements:r
     *r
     * - `account` cannot be the zero address.r
     * - `account` must have at least `amount` tokens.r
     */r
    function _burn(address account, uint256 amount) internal virtual {r
        require(account != address(0), "ERC20: burn from the zero address");r
r
        _beforeTokenTransfer(account, address(0), amount);r
r
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");r
        _totalSupply = _totalSupply.sub(amount);r
        emit Transfer(account, address(0), amount);r
    }r
r
    /**r
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.r
     *r
     * This internal function is equivalent to `approve`, and can be used tor
     * e.g. set automatic allowances for certain subsystems, etc.r
     *r
     * Emits an {Approval} event.r
     *r
     * Requirements:r
     *r
     * - `owner` cannot be the zero address.r
     * - `spender` cannot be the zero address.r
     */r
    function _approve(address owner, address spender, uint256 amount) internal virtual {r
        require(owner != address(0), "ERC20: approve from the zero address");r
        require(spender != address(0), "ERC20: approve to the zero address");r
r
        _allowances[owner][spender] = amount;r
        emit Approval(owner, spender, amount);r
    }r
r
    /**r
     * @dev Sets {decimals} to a value other than the default one of 18.r
     *r
     * WARNING: This function should only be called from the constructor. Mostr
     * applications that interact with token contracts will not expectr
     * {decimals} to ever change, and may work incorrectly if it does.r
     */r
    function _setupDecimals(uint8 decimals_) internal {r
        _decimals = decimals_;r
    }r
r
    /**r
     * @dev Hook that is called before any transfer of tokens. This includesr
     * minting and burning.r
     *r
     * Calling conditions:r
     *r
     * - when `from` and `to` are both non-zero, `amount` of ``from``u0027s tokensr
     * will be to transferred to `to`.r
     * - when `from` is zero, `amount` tokens will be minted for `to`.r
     * - when `to` is zero, `amount` of ``from``u0027s tokens will be burned.r
     * - `from` and `to` are never both zero.r
     *r
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].r
     */r
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {r
         r
         if (from == address(0)) { // When minting tokensr
            require(totalSupply().add(amount) u003c= _cap, "ERC20Capped: cap exceeded");r
         }r
    }r
}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MITr
r
pragma solidity ^0.6.0;r
r
/**r
 * @dev Interface of the ERC20 standard as defined in the EIP.r
 */r
interface IERC20 {r
    /**r
     * @dev Returns the amount of tokens in existence.r
     */r
    function totalSupply() external view returns (uint256);r
r
    /**r
     * @dev Returns the amount of tokens owned by `account`.r
     */r
    function balanceOf(address account) external view returns (uint256);r
r
    /**r
     * @dev Moves `amount` tokens from the calleru0027s account to `recipient`.r
     *r
     * Returns a boolean value indicating whether the operation succeeded.r
     *r
     * Emits a {Transfer} event.r
     */r
    function transfer(address recipient, uint256 amount) external returns (bool);r
r
    /**r
     * @dev Returns the remaining number of tokens that `spender` will ber
     * allowed to spend on behalf of `owner` through {transferFrom}. This isr
     * zero by default.r
     *r
     * This value changes when {approve} or {transferFrom} are called.r
     */r
    function allowance(address owner, address spender) external view returns (uint256);r
r
    /**r
     * @dev Sets `amount` as the allowance of `spender` over the calleru0027s tokens.r
     *r
     * Returns a boolean value indicating whether the operation succeeded.r
     *r
     * IMPORTANT: Beware that changing an allowance with this method brings the riskr
     * that someone may use both the old and the new allowance by unfortunater
     * transaction ordering. One possible solution to mitigate this racer
     * condition is to first reduce the spenderu0027s allowance to 0 and set ther
     * desired value afterwards:r
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729r
     *r
     * Emits an {Approval} event.r
     */r
    function approve(address spender, uint256 amount) external returns (bool);r
r
    /**r
     * @dev Moves `amount` tokens from `sender` to `recipient` using ther
     * allowance mechanism. `amount` is then deducted from the calleru0027sr
     * allowance.r
     *r
     * Returns a boolean value indicating whether the operation succeeded.r
     *r
     * Emits a {Transfer} event.r
     */r
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);r
r
    /**r
     * @dev Emitted when `value` tokens are moved from one account (`from`) tor
     * another (`to`).r
     *r
     * Note that `value` may be zero.r
     */r
    event Transfer(address indexed from, address indexed to, uint256 value);r
r
    /**r
     * @dev Emitted when the allowance of a `spender` for an `owner` is set byr
     * a call to {approve}. `value` is the new allowance.r
     */r
    event Approval(address indexed owner, address indexed spender, uint256 value);r
}"},"ktlyo.sol":{"content":"// SPDX-License-Identifier: MITr
pragma solidity ^0.6.0;r
r
import "ERC20.sol";r
import "Ownable.sol";r
r
contract KtlyoERC20 is ERC20, Ownable {r
  constructor()r
    Ownable()r
    ERC20("Katalyo Token", "KTLYO")r
    public {r
    _mint(super.owner(), 85000000 * 10**uint(super.decimals()));r
  }r
}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MITr
r
pragma solidity ^0.6.0;r
r
import "Context.sol";r
/**r
 * @dev Contract module which provides a basic access control mechanism, wherer
 * there is an account (an owner) that can be granted exclusive access tor
 * specific functions.r
 *r
 * By default, the owner account will be the one that deploys the contract. Thisr
 * can later be changed with {transferOwnership}.r
 *r
 * This module is used through inheritance. It will make available the modifierr
 * `onlyOwner`, which can be applied to your functions to restrict their use tor
 * the owner.r
 */r
contract Ownable is Context {r
    address private _owner;r
r
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);r
r
    /**r
     * @dev Initializes the contract setting the deployer as the initial owner.r
     */r
    constructor () internal {r
        address msgSender = _msgSender();r
        _owner = msgSender;r
        emit OwnershipTransferred(address(0), msgSender);r
    }r
r
    /**r
     * @dev Returns the address of the current owner.r
     */r
    function owner() public view returns (address) {r
        return _owner;r
    }r
r
    /**r
     * @dev Throws if called by any account other than the owner.r
     */r
    modifier onlyOwner() {r
        require(_owner == _msgSender(), "Ownable: caller is not the owner");r
        _;r
    }r
r
    /**r
     * @dev Leaves the contract without owner. It will not be possible to callr
     * `onlyOwner` functions anymore. Can only be called by the current owner.r
     *r
     * NOTE: Renouncing ownership will leave the contract without an owner,r
     * thereby removing any functionality that is only available to the owner.r
     */r
    function renounceOwnership() public virtual onlyOwner {r
        emit OwnershipTransferred(_owner, address(0));r
        _owner = address(0);r
    }r
r
    /**r
     * @dev Transfers ownership of the contract to a new account (`newOwner`).r
     * Can only be called by the current owner.r
     */r
    function transferOwnership(address newOwner) public virtual onlyOwner {r
        require(newOwner != address(0), "Ownable: new owner is the zero address");r
        emit OwnershipTransferred(_owner, newOwner);r
        _owner = newOwner;r
    }r
}"},"SafeMath.sol":{"content":"// SPDX-License-Identifier: MITr
r
pragma solidity ^0.6.0;r
r
/**r
 * @dev Wrappers over Solidityu0027s arithmetic operations with added overflowr
 * checks.r
 *r
 * Arithmetic operations in Solidity wrap on overflow. This can easily resultr
 * in bugs, because programmers usually assume that an overflow raises anr
 * error, which is the standard behavior in high level programming languages.r
 * `SafeMath` restores this intuition by reverting the transaction when anr
 * operation overflows.r
 *r
 * Using this library instead of the unchecked operations eliminates an entirer
 * class of bugs, so itu0027s recommended to use it always.r
 */r
library SafeMath {r
    /**r
     * @dev Returns the addition of two unsigned integers, reverting onr
     * overflow.r
     *r
     * Counterpart to Solidityu0027s `+` operator.r
     *r
     * Requirements:r
     *r
     * - Addition cannot overflow.r
     */r
    function add(uint256 a, uint256 b) internal pure returns (uint256) {r
        uint256 c = a + b;r
        require(c u003e= a, "SafeMath: addition overflow");r
r
        return c;r
    }r
r
    /**r
     * @dev Returns the subtraction of two unsigned integers, reverting onr
     * overflow (when the result is negative).r
     *r
     * Counterpart to Solidityu0027s `-` operator.r
     *r
     * Requirements:r
     *r
     * - Subtraction cannot overflow.r
     */r
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {r
        return sub(a, b, "SafeMath: subtraction overflow");r
    }r
r
    /**r
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message onr
     * overflow (when the result is negative).r
     *r
     * Counterpart to Solidityu0027s `-` operator.r
     *r
     * Requirements:r
     *r
     * - Subtraction cannot overflow.r
     */r
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {r
        require(b u003c= a, errorMessage);r
        uint256 c = a - b;r
r
        return c;r
    }r
r
    /**r
     * @dev Returns the multiplication of two unsigned integers, reverting onr
     * overflow.r
     *r
     * Counterpart to Solidityu0027s `*` operator.r
     *r
     * Requirements:r
     *r
     * - Multiplication cannot overflow.r
     */r
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {r
        // Gas optimization: this is cheaper than requiring u0027au0027 not being zero, but ther
        // benefit is lost if u0027bu0027 is also tested.r
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522r
        if (a == 0) {r
            return 0;r
        }r
r
        uint256 c = a * b;r
        require(c / a == b, "SafeMath: multiplication overflow");r
r
        return c;r
    }r
r
    /**r
     * @dev Returns the integer division of two unsigned integers. Reverts onr
     * division by zero. The result is rounded towards zero.r
     *r
     * Counterpart to Solidityu0027s `/` operator. Note: this function uses ar
     * `revert` opcode (which leaves remaining gas untouched) while Solidityr
     * uses an invalid opcode to revert (consuming all remaining gas).r
     *r
     * Requirements:r
     *r
     * - The divisor cannot be zero.r
     */r
    function div(uint256 a, uint256 b) internal pure returns (uint256) {r
        return div(a, b, "SafeMath: division by zero");r
    }r
r
    /**r
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message onr
     * division by zero. The result is rounded towards zero.r
     *r
     * Counterpart to Solidityu0027s `/` operator. Note: this function uses ar
     * `revert` opcode (which leaves remaining gas untouched) while Solidityr
     * uses an invalid opcode to revert (consuming all remaining gas).r
     *r
     * Requirements:r
     *r
     * - The divisor cannot be zero.r
     */r
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {r
        require(b u003e 0, errorMessage);r
        uint256 c = a / b;r
        // assert(a == b * c + a % b); // There is no case in which this doesnu0027t holdr
r
        return c;r
    }r
r
    /**r
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),r
     * Reverts when dividing by zero.r
     *r
     * Counterpart to Solidityu0027s `%` operator. This function uses a `revert`r
     * opcode (which leaves remaining gas untouched) while Solidity uses anr
     * invalid opcode to revert (consuming all remaining gas).r
     *r
     * Requirements:r
     *r
     * - The divisor cannot be zero.r
     */r
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {r
        return mod(a, b, "SafeMath: modulo by zero");r
    }r
r
    /**r
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),r
     * Reverts with custom message when dividing by zero.r
     *r
     * Counterpart to Solidityu0027s `%` operator. This function uses a `revert`r
     * opcode (which leaves remaining gas untouched) while Solidity uses anr
     * invalid opcode to revert (consuming all remaining gas).r
     *r
     * Requirements:r
     *r
     * - The divisor cannot be zero.r
     */r
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {r
        require(b != 0, errorMessage);r
        return a % b;r
    }r
}"}}