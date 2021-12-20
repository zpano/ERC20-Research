{{
  "language": "Solidity",
  "sources": {
    "/contracts/tokens/Vader.sol": {
      "content": "// SPDX-License-Identifier: MIT AND AGPL-3.0-or-laterr
r
pragma solidity =0.8.9;r
r
import "@openzeppelin/contracts/access/Ownable.sol";r
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";r
r
import "../shared/ProtocolConstants.sol";r
r
import "../interfaces/tokens/IUSDV.sol";r
import "../interfaces/tokens/IVader.sol";r
import "../interfaces/tokens/vesting/ILinearVesting.sol";r
import "../interfaces/tokens/converter/IConverter.sol";r
r
/**r
 * @dev Implementation of the {IVader} interface.r
 *r
 * The Vader token that acts as the backbone of the Vader protocol,r
 * burned and minted to mint and burn USDV tokens respectively.r
 *r
 * The token has a fixed initial supply at 25 billion units that is meant to thenr
 * fluctuate depending on the amount of USDV minted into and burned from circulation.r
 *r
 * Emissions are initially controlled by the Vader team and then will be governedr
 * by the DAO.r
 */r
contract Vader is IVader, ProtocolConstants, ERC20, Ownable {r
    /* ========== STATE VARIABLES ========== */r
r
    // The Vader <-> Vether converter contractr
    IConverter public converter;r
r
    // The Vader Team vesting contractr
    ILinearVesting public vest;r
r
    // The USDV contract, used to apply proper access controlr
    IUSDV public usdv;r
r
    // The initial maximum supply of the token, equivalent to 25 bn unitsr
    uint256 public maxSupply = _INITIAL_VADER_SUPPLY;r
r
    /* ========== CONSTRUCTOR ========== */r
r
    /**r
     * @dev Mints the ecosystem growth fund and grant allocation amount described in the whitepaper to ther
     * token contract itself.r
     *r
     * As the token is meant to be minted and burned freely between USDV and itself,r
     * there is no real initialization taking place apart from the initially mintedr
     * supply for the following components:r
     *r
     * - Grant Allocation: The amount of funds meant to be distributed by the DAO as grants to expand the protocolr
     *r
     * - Ecosystem Growth: An allocation that is released to strategic partners for ther
     * protocol's expansionr
     *r
     * The latter two of the allocations are minted at a later date given that the addresses ofr
     * the converter and vesting contract are not known on deployment.r
     */r
    constructor() ERC20("Vader", "VADER") {r
        _mint(address(this), _GRANT_ALLOCATION);r
        _mint(address(this), _ECOSYSTEM_GROWTH);r
    }r
r
    /* ========== MUTATIVE FUNCTIONS ========== */r
r
    /**r
     * @dev Creates a manual emission eventr
     *r
     * Emits an {Emission} event indicating the amount emitted as well as what the currentr
     * era's timestamp is.r
     */r
    function createEmission(address user, uint256 amount)r
        externalr
        overrider
        onlyOwnerr
    {r
        _transfer(address(this), user, amount);r
        emit Emission(user, amount);r
    }r
r
    /* ========== RESTRICTED FUNCTIONS ========== */r
r
    /**r
     * @dev Sets the initial {converter} and {vest} contract addresses. Additionally, mintsr
     * the Vader amount available for conversion as well as the team allocation that is meantr
     * to be vested to each respective contract.r
     *r
     * Emits a {ProtocolInitialized} event indicating all the supplied values of the function.r
     *r
     * Requirements:r
     *r
     * - the caller must be the deployer of the contractr
     * - the contract must not have already been initializedr
     */r
    function setComponents(r
        IConverter _converter,r
        ILinearVesting _vest,r
        address[] calldata vesters,r
        uint192[] calldata amountsr
    ) external onlyOwner {r
        require(r
            _converter != IConverter(_ZERO_ADDRESS) &&r
                _vest != ILinearVesting(_ZERO_ADDRESS),r
            "Vader::setComponents: Incorrect Arguments"r
        );r
        require(r
            converter == IConverter(_ZERO_ADDRESS),r
            "Vader::setComponents: Already Set"r
        );r
r
        converter = _converter;r
        vest = _vest;r
r
        _mint(address(_converter), _VETH_ALLOCATION);r
        _mint(address(_vest), _TEAM_ALLOCATION);r
r
        _vest.begin(vesters, amounts);r
r
        emit ProtocolInitialized(r
            address(_converter),r
            address(_vest)r
        );r
    }r
r
    /**r
     * @dev Set USDVr
     * Emits a {USDVSet} event indicating that USDV is setr
     *r
     * Requirements:r
     *r
     * - the caller must be ownerr
     * - USDV must be of a non-zero addressr
     * - USDV must not be setr
     */r
    function setUSDV(IUSDV _usdv) external onlyOwner {r
        require(_usdv != IUSDV(_ZERO_ADDRESS), "Vader::setUSDV: Invalid USDV address");r
        require(usdv == IUSDV(_ZERO_ADDRESS), "Vader::setUSDV: USDV already set");r
r
        usdv = _usdv;r
        emit USDVSet(address(_usdv));r
    }r
r
    /**r
     * @dev Allows a strategic partnership grant to be claimed.r
     *r
     * Emits a {GrantClaimed} event indicating the beneficiary of the grant asr
     * well as the grant amount.r
     *r
     * Requirements:r
     *r
     * - the caller must be the DAOr
     * - the token must hold sufficient Vader allocation for the grantr
     * - the grant must be of a non-zero amountr
     */r
    function claimGrant(address beneficiary, uint256 amount) external onlyOwner {r
        require(amount != 0, "Vader::claimGrant: Non-Zero Amount Required");r
        emit GrantClaimed(beneficiary, amount);r
        _transfer(address(this), beneficiary, amount);r
    }r
r
    /**r
     * @dev Allows the maximum supply of the token to be adjusted.r
     *r
     * Emits an {MaxSupplyChanged} event indicating the previous and next maximumr
     * total supplies.r
     *r
     * Requirements:r
     *r
     * - the caller must be the DAOr
     * - the new maximum supply must be greater than the current supplyr
     */r
    function adjustMaxSupply(uint256 _maxSupply) external onlyOwner {r
        require(r
            _maxSupply >= totalSupply(),r
            "Vader::adjustMaxSupply: Max supply cannot subcede current supply"r
        );r
        emit MaxSupplyChanged(maxSupply, _maxSupply);r
        maxSupply = _maxSupply;r
    }r
r
    /**r
     * @dev Allows the USDV token to perform mints of VADER tokensr
     *r
     * Emits an ERC-20 {Transfer} event signaling the minting operation.r
     *r
     * Requirements:r
     *r
     * - the caller must be the USDVr
     * - the new supply must be below the maximum supplyr
     */r
    function mint(address _user, uint256 _amount) external onlyUSDV {r
        require(r
            maxSupply >= totalSupply() + _amount,r
            "Vader::mint: Max supply reached"r
        );r
        _mint(_user, _amount);r
    }r
r
    /**r
     * @dev Allows the USDV token to perform burns of VADER tokensr
     *r
     * Emits an ERC-20 {Transfer} event signaling the burning operation.r
     *r
     * Requirements:r
     *r
     * - the caller must be the USDVr
     * - the USDV contract must have a sufficient VADER balancer
     */r
    function burn(uint256 _amount) external onlyUSDV {r
        _burn(msg.sender, _amount);r
    }r
r
    /* ========== INTERNAL FUNCTIONS ========== */r
r
    /* ========== PRIVATE FUNCTIONS ========== */r
r
    /**r
     * @dev Ensures only the USDV is able to invoke a particular function by validating that ther
     * contract has been set up and that the msg.sender is the USDV addressr
     */r
    function _onlyUSDV() private view {r
        require(r
            address(usdv) == msg.sender,r
            "Vader::_onlyUSDV: Insufficient Privileges"r
        );r
    }r
r
    /* ========== MODIFIERS ========== */r
r
    /**r
     * @dev Throws if invoked by anyone else other than the USDVr
     */r
    modifier onlyUSDV() {r
        _onlyUSDV();r
        _;r
    }r
}r
"
    },
    "/contracts/shared/ProtocolConstants.sol": {
      "content": "// SPDX-License-Identifier: MIT AND AGPL-3.0-or-laterr
pragma solidity =0.8.9;r
r
abstract contract ProtocolConstants {r
    /* ========== GENERAL ========== */r
r
    // The zero address, utilityr
    address internal constant _ZERO_ADDRESS = address(0);r
r
    // One year, utilityr
    uint256 internal constant _ONE_YEAR = 365 days;r
r
    // Basis Pointsr
    uint256 internal constant _MAX_BASIS_POINTS = 100_00;r
r
    /* ========== VADER TOKEN ========== */r
r
    // Max VADER supplyr
    uint256 internal constant _INITIAL_VADER_SUPPLY = 25_000_000_000 * 1 ether;r
r
    // Allocation for VETH holdersr
    uint256 internal constant _VETH_ALLOCATION = 7_500_000_000 * 1 ether;r
r
    // Team allocation vested over {VESTING_DURATION} yearsr
    uint256 internal constant _TEAM_ALLOCATION = 2_500_000_000 * 1 ether;r
r
    // Ecosystem growth fund unlocked for partnerships & USDV provisionr
    uint256 internal constant _ECOSYSTEM_GROWTH = 2_500_000_000 * 1 ether;r
r
    // Total grant tokensr
    uint256 internal constant _GRANT_ALLOCATION = 12_500_000_000 * 1 ether;r
r
    // Emission Erar
    uint256 internal constant _EMISSION_ERA = 24 hours;r
r
    // Initial Emission Curve, 5r
    uint256 internal constant _INITIAL_EMISSION_CURVE = 5;r
r
    // Fee Basis Pointsr
    uint256 internal constant _MAX_FEE_BASIS_POINTS = 1_00;r
r
    /* ========== VESTING ========== */r
r
    // Vesting Durationr
    uint256 internal constant _VESTING_DURATION = 2 * _ONE_YEAR;r
r
    /* ========== CONVERTER ========== */r
r
    // Vader -> Vether Conversion Rate (1000:1)r
    uint256 internal constant _VADER_VETHER_CONVERSION_RATE = 10_000;r
r
    // Burn Addressr
    address internal constant _BURN =r
        0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD;r
r
    /* ========== SWAP QUEUE ========== */r
r
    // A minimum of 10 swaps will be executed per blockr
    uint256 internal constant _MIN_SWAPS_EXECUTED = 10;r
r
    // Expressed in basis points (50%)r
    uint256 internal constant _DEFAULT_SWAPS_EXECUTED = 50_00;r
r
    // The queue size of each block is 100 unitsr
    uint256 internal constant _QUEUE_SIZE = 100;r
r
    /* ========== GAS QUEUE ========== */r
r
    // Address of Chainlink Fast Gas Price Oracler
    address internal constant _FAST_GAS_ORACLE =r
        0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C;r
r
    /* ========== VADER RESERVE ========== */r
r
    // Minimum delay between grantsr
    uint256 internal constant _GRANT_DELAY = 30 days;r
r
    // Maximum grant size divisorr
    uint256 internal constant _MAX_GRANT_BASIS_POINTS = 10_00;r
}r
"
    },
    "/contracts/interfaces/tokens/vesting/ILinearVesting.sol": {
      "content": "// SPDX-License-Identifier: MIT AND AGPL-3.0-or-laterr
pragma solidity =0.8.9;r
r
interface ILinearVesting {r
    /* ========== STRUCTS ========== */r
r
    // Struct of a vesting member, tight-packed to 256-bitsr
    struct Vester {r
        uint192 amount;r
        uint64 lastClaim;r
        uint128 start;r
        uint128 end;r
    }r
r
    /* ========== FUNCTIONS ========== */r
r
    function getClaim(address _vester)r
        externalr
        viewr
        returns (uint256 vestedAmount);r
r
    function claim() external returns (uint256 vestedAmount);r
r
    //    function claimConverted() external returns (uint256 vestedAmount);r
r
    function begin(address[] calldata vesters, uint192[] calldata amounts)r
        external;r
r
    function vestFor(address user, uint256 amount) external;r
r
    /* ========== EVENTS ========== */r
r
    event VestingInitialized(uint256 duration);r
r
    event VestingCreated(address user, uint256 amount);r
r
    event Vested(address indexed from, uint256 amount);r
}r
"
    },
    "/contracts/interfaces/tokens/converter/IConverter.sol": {
      "content": "// SPDX-License-Identifier: MIT AND AGPL-3.0-or-laterr
pragma solidity =0.8.9;r
r
interface IConverter {r
    /* ========== FUNCTIONS ========== */r
r
    function convert(bytes32[] calldata proof, uint256 amount, uint256 minVader)r
        externalr
        returns (uint256 vaderReceived);r
r
    /* ========== EVENTS ========== */r
r
    event Conversion(r
        address indexed user,r
        uint256 vetherAmount,r
        uint256 vaderAmountr
    );r
}r
"
    },
    "/contracts/interfaces/tokens/IVader.sol": {
      "content": "// SPDX-License-Identifier: MIT AND AGPL-3.0-or-laterr
pragma solidity =0.8.9;r
r
interface IVader {r
    /* ========== FUNCTIONS ========== */r
r
    function createEmission(address user, uint256 amount) external;r
r
    /* ========== EVENTS ========== */r
r
    event Emission(address to, uint256 amount);r
r
    event EmissionChanged(uint256 previous, uint256 next);r
r
    event MaxSupplyChanged(uint256 previous, uint256 next);r
r
    event GrantClaimed(address indexed beneficiary, uint256 amount);r
r
    event ProtocolInitialized(r
        address converter,r
        address vestr
    );r
r
    event USDVSet(address usdv);r
r
    /* ========== DEPRECATED ========== */r
r
    // function getCurrentEraEmission() external view returns (uint256);r
r
    // function getEraEmission(uint256 currentSupply)r
    //     externalr
    //     viewr
    //     returns (uint256);r
r
    // function calculateFee() external view returns (uint256 basisPoints);r
}r
"
    },
    "/contracts/interfaces/tokens/IUSDV.sol": {
      "content": "// SPDX-License-Identifier: MIT AND AGPL-3.0-or-laterr
pragma solidity =0.8.9;r
r
interface IUSDV {r
    /* ========== STRUCTS ========== */r
    /* ========== FUNCTIONS ========== */r
    /* ========== EVENTS ========== */r
}r
"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
"
    },
    "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol": {
      "content": "// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
"
    },
    "@openzeppelin/contracts/token/ERC20/ERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
"
    },
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
"
    }
  },
  "settings": {
    "remappings": [],
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "evmVersion": "london",
    "libraries": {},
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  }
}}