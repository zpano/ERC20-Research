{{
  "language": "Solidity",
  "sources": {
    "/C/Users/kdmcg/Documents/Grumpy_Pawth_Swap/src/contracts/Pawthereum.sol": {
      "content": "pragma solidity ^0.6.12;r
r
abstract contract Context {r
    function _msgSender() internal view virtual returns (address payable) {r
        return msg.sender;r
    }r
r
    function _msgData() internal view virtual returns (bytes memory) {r
        this;r
        return msg.data;r
    }r
}r
r
interface IERC20 {r
    function totalSupply() external view returns (uint256);r
r
    function balanceOf(address account) external view returns (uint256);r
r
    function transfer(address recipient, uint256 amount)r
        externalr
        returns (bool);r
r
    function allowance(address owner, address spender)r
        externalr
        viewr
        returns (uint256);r
r
    function approve(address spender, uint256 amount) external returns (bool);r
r
    function transferFrom(r
        address sender,r
        address recipient,r
        uint256 amountr
    ) external returns (bool);r
r
    event Transfer(address indexed from, address indexed to, uint256 value);r
    event Approval(r
        address indexed owner,r
        address indexed spender,r
        uint256 valuer
    );r
}r
r
library SafeMath {r
    function add(uint256 a, uint256 b) internal pure returns (uint256) {r
        uint256 c = a + b;r
        require(c >= a, "SafeMath: addition overflow");r
r
        return c;r
    }r
r
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {r
        return sub(a, b, "SafeMath: subtraction overflow");r
    }r
r
    function sub(r
        uint256 a,r
        uint256 b,r
        string memory errorMessager
    ) internal pure returns (uint256) {r
        require(b <= a, errorMessage);r
        uint256 c = a - b;r
r
        return c;r
    }r
r
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {r
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {r
        return div(a, b, "SafeMath: division by zero");r
    }r
r
    function div(r
        uint256 a,r
        uint256 b,r
        string memory errorMessager
    ) internal pure returns (uint256) {r
        require(b > 0, errorMessage);r
        uint256 c = a / b;r
r
        return c;r
    }r
r
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {r
        return mod(a, b, "SafeMath: modulo by zero");r
    }r
r
    function mod(r
        uint256 a,r
        uint256 b,r
        string memory errorMessager
    ) internal pure returns (uint256) {r
        require(b != 0, errorMessage);r
        return a % b;r
    }r
}r
r
library Address {r
    function isContract(address account) internal view returns (bool) {r
        bytes32 codehash;r
r
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;r
        assembly {r
            codehash := extcodehash(account)r
        }r
        return (codehash != accountHash && codehash != 0x0);r
    }r
r
    function sendValue(address payable recipient, uint256 amount) internal {r
        require(r
            address(this).balance >= amount,r
            "Address: insufficient balance"r
        );r
r
        (bool success, ) = recipient.call{value: amount}("");r
        require(r
            success,r
            "Address: unable to send value, recipient may have reverted"r
        );r
    }r
r
    function functionCall(address target, bytes memory data)r
        internalr
        returns (bytes memory)r
    {r
        return functionCall(target, data, "Address: low-level call failed");r
    }r
r
    function functionCall(r
        address target,r
        bytes memory data,r
        string memory errorMessager
    ) internal returns (bytes memory) {r
        return _functionCallWithValue(target, data, 0, errorMessage);r
    }r
r
    function functionCallWithValue(r
        address target,r
        bytes memory data,r
        uint256 valuer
    ) internal returns (bytes memory) {r
        returnr
            functionCallWithValue(r
                target,r
                data,r
                value,r
                "Address: low-level call with value failed"r
            );r
    }r
r
    function functionCallWithValue(r
        address target,r
        bytes memory data,r
        uint256 value,r
        string memory errorMessager
    ) internal returns (bytes memory) {r
        require(r
            address(this).balance >= value,r
            "Address: insufficient balance for call"r
        );r
        return _functionCallWithValue(target, data, value, errorMessage);r
    }r
r
    function _functionCallWithValue(r
        address target,r
        bytes memory data,r
        uint256 weiValue,r
        string memory errorMessager
    ) private returns (bytes memory) {r
        require(isContract(target), "Address: call to non-contract");r
r
        // solhint-disable-next-line avoid-low-level-callsr
        (bool success, bytes memory returndata) = target.call{value: weiValue}(r
            datar
        );r
        if (success) {r
            return returndata;r
        } else {r
            if (returndata.length > 0) {r
                assembly {r
                    let returndata_size := mload(returndata)r
                    revert(add(32, returndata), returndata_size)r
                }r
            } else {r
                revert(errorMessage);r
            }r
        }r
    }r
}r
r
contract Ownable is Context {r
    address private _owner;r
r
    event OwnershipTransferred(r
        address indexed previousOwner,r
        address indexed newOwnerr
    );r
r
    constructor() internal {r
        address msgSender = _msgSender();r
        _owner = msgSender;r
        emit OwnershipTransferred(address(0), msgSender);r
    }r
r
    function owner() public view returns (address) {r
        return _owner;r
    }r
r
    modifier onlyOwner() {r
        require(_owner == _msgSender(), "Ownable: caller is not the owner");r
        _;r
    }r
r
    function renounceOwnership() public virtual onlyOwner {r
        emit OwnershipTransferred(_owner, address(0));r
        _owner = address(0);r
    }r
r
    function transferOwnership(address newOwner) public virtual onlyOwner {r
        require(r
            newOwner != address(0),r
            "Ownable: new owner is the zero address"r
        );r
        emit OwnershipTransferred(_owner, newOwner);r
        _owner = newOwner;r
    }r
}r
r
interface IUniswapV2Factory {r
    function createPair(address tokenA, address tokenB)r
        externalr
        returns (address pair);r
}r
r
interface IUniswapV2Pair {r
    function sync() external;r
}r
r
interface IUniswapV2Router01 {r
    function factory() external pure returns (address);r
r
    function WETH() external pure returns (address);r
r
    function addLiquidity(r
        address tokenA,r
        address tokenB,r
        uint256 amountADesired,r
        uint256 amountBDesired,r
        uint256 amountAMin,r
        uint256 amountBMin,r
        address to,r
        uint256 deadliner
    )r
        externalr
        returns (r
            uint256 amountA,r
            uint256 amountB,r
            uint256 liquidityr
        );r
r
    function addLiquidityETH(r
        address token,r
        uint256 amountTokenDesired,r
        uint256 amountTokenMin,r
        uint256 amountETHMin,r
        address to,r
        uint256 deadliner
    )r
        externalr
        payabler
        returns (r
            uint256 amountToken,r
            uint256 amountETH,r
            uint256 liquidityr
        );r
}r
r
interface IUniswapV2Router02 is IUniswapV2Router01 {r
    function removeLiquidityETHSupportingFeeOnTransferTokens(r
        address token,r
        uint256 liquidity,r
        uint256 amountTokenMin,r
        uint256 amountETHMin,r
        address to,r
        uint256 deadliner
    ) external returns (uint256 amountETH);r
r
    function swapExactTokensForETHSupportingFeeOnTransferTokens(r
        uint256 amountIn,r
        uint256 amountOutMin,r
        address[] calldata path,r
        address to,r
        uint256 deadliner
    ) external;r
r
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(r
        uint256 amountIn,r
        uint256 amountOutMin,r
        address[] calldata path,r
        address to,r
        uint256 deadliner
    ) external;r
r
    function swapExactETHForTokensSupportingFeeOnTransferTokens(r
        uint256 amountOutMin,r
        address[] calldata path,r
        address to,r
        uint256 deadliner
    ) external payable;r
}r
r
// change "name1" into ur namer
contract Pawthereum is Context, IERC20, Ownable {r
    using SafeMath for uint256;r
    using Address for address;r
r
    //change "name1" and "symbol"r
    string private _name = "Pawthereum";r
    string private _symbol = "PAWTH";r
r
    uint8 private _decimals = 9;r
r
    mapping(address => uint256) internal _reflectionBalance;r
    mapping(address => uint256) internal _tokenBalance;r
    mapping(address => mapping(address => uint256)) internal _allowances;r
r
    uint256 private constant MAX = ~uint256(0);r
r
    // change this for total supply (100e8 = 100) (100000000e8 = 100000000) (dont forget the e8 it has to be there)r
    uint256 internal _tokenTotal = 1000000000e9;r
    // change this for total supply ^^^^^^^^^^^^^^^^^^^^^r
    uint256 internal _reflectionTotal = (MAX - (MAX % _tokenTotal));r
r
    mapping(address => bool) isTaxless;r
    mapping(address => bool) internal _isExcluded;r
    address[] internal _excluded;r
r
    uint256 public _feeDecimal = 2;r
    // thats the distribution to holders (400 = 4%)r
    uint256 public _taxFee = 200;r
    // thats the amount for liquidity poolr
    uint256 public _liquidityFee = 100;r
    // this amount gets burned by every transactionr
    uint256 public _burnFee = 0;r
    // this goes to the marketing wallet (line 403)r
    uint256 public _marketingFee = 100;r
    // this goes to the charity walletr
    uint256 public _charityFee = 200;r
r
    uint256 public _taxFeeTotal;r
    uint256 public _burnFeeTotal;r
    uint256 public _liquidityFeeTotal;r
    uint256 public _marketingFeeTotal;r
    uint256 public _charityFeeTotal;r
r
    address public marketingWallet;r
    address public charityWallet;r
r
    bool public isTaxActive = true;r
    bool private inSwapAndLiquify;r
    bool public swapAndLiquifyEnabled = true;r
r
    uint256 public maxTxAmount = _tokenTotal;r
    uint256 public minTokensBeforeSwap = 10_000e9;r
r
    IUniswapV2Router02 public uniswapV2Router;r
    address public uniswapV2Pair;r
r
    event SwapAndLiquifyEnabledUpdated(bool enabled);r
    event SwapAndLiquify(r
        uint256 tokensSwapped,r
        uint256 ethReceived,r
        uint256 tokensIntoLiqudityr
    );r
r
    modifier lockTheSwap() {r
        inSwapAndLiquify = true;r
        _;r
        inSwapAndLiquify = false;r
    }r
r
    constructor() public {r
        marketingWallet = 0x6DFcd4331b0d86bfe0318706C76B832dA4C03C1B;r
r
        charityWallet = 0xa56891cfBd0175E6Fc46Bf7d647DE26100e95C78;r
r
        isTaxless[_msgSender()] = true;r
        isTaxless[address(this)] = true;r
r
        _reflectionBalance[_msgSender()] = _reflectionTotal;r
        emit Transfer(address(0), _msgSender(), _tokenTotal);r
    }r
r
    function init() external onlyOwner {r
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); // for BSCr
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(r
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488Dr
        ); // for Ethereumr
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506); // for Sushi testnetr
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())r
            .createPair(address(this), _uniswapV2Router.WETH());r
        uniswapV2Router = _uniswapV2Router;r
    }r
r
    function name() public view returns (string memory) {r
        return _name;r
    }r
r
    function symbol() public view returns (string memory) {r
        return _symbol;r
    }r
r
    function decimals() public view returns (uint8) {r
        return _decimals;r
    }r
r
    function totalSupply() public view override returns (uint256) {r
        return _tokenTotal;r
    }r
r
    function balanceOf(address account) public view override returns (uint256) {r
        if (_isExcluded[account]) return _tokenBalance[account];r
        return tokenFromReflection(_reflectionBalance[account]);r
    }r
r
    function transfer(address recipient, uint256 amount)r
        publicr
        virtualr
        overrider
        returns (bool)r
    {r
        _transfer(_msgSender(), recipient, amount);r
        return true;r
    }r
r
    function allowance(address owner, address spender)r
        publicr
        viewr
        overrider
        returns (uint256)r
    {r
        return _allowances[owner][spender];r
    }r
r
    function approve(address spender, uint256 amount)r
        publicr
        overrider
        returns (bool)r
    {r
        _approve(_msgSender(), spender, amount);r
        return true;r
    }r
r
    function transferFrom(r
        address sender,r
        address recipient,r
        uint256 amountr
    ) public virtual override returns (bool) {r
        _transfer(sender, recipient, amount);r
r
        _approve(r
            sender,r
            _msgSender(),r
            _allowances[sender][_msgSender()].sub(r
                amount,r
                "ERC20: transfer amount exceeds allowance"r
            )r
        );r
        return true;r
    }r
r
    function increaseAllowance(address spender, uint256 addedValue)r
        publicr
        virtualr
        returns (bool)r
    {r
        _approve(r
            _msgSender(),r
            spender,r
            _allowances[_msgSender()][spender].add(addedValue)r
        );r
        return true;r
    }r
r
    function decreaseAllowance(address spender, uint256 subtractedValue)r
        publicr
        virtualr
        returns (bool)r
    {r
        _approve(r
            _msgSender(),r
            spender,r
            _allowances[_msgSender()][spender].sub(r
                subtractedValue,r
                "ERC20: decreased allowance below zero"r
            )r
        );r
        return true;r
    }r
r
    function isExcluded(address account) public view returns (bool) {r
        return _isExcluded[account];r
    }r
r
    function reflectionFromToken(uint256 tokenAmount, bool deductTransferFee)r
        publicr
        viewr
        returns (uint256)r
    {r
        require(tokenAmount <= _tokenTotal, "Amount must be less than supply");r
        if (!deductTransferFee) {r
            return tokenAmount.mul(_getReflectionRate());r
        } else {r
            returnr
                tokenAmountr
                    .sub(tokenAmount.mul(_taxFee).div(10**_feeDecimal + 2))r
                    .mul(_getReflectionRate());r
        }r
    }r
r
    function tokenFromReflection(uint256 reflectionAmount)r
        publicr
        viewr
        returns (uint256)r
    {r
        require(r
            reflectionAmount <= _reflectionTotal,r
            "Amount must be less than total reflections"r
        );r
        uint256 currentRate = _getReflectionRate();r
        return reflectionAmount.div(currentRate);r
    }r
r
    function excludeAccount(address account) external onlyOwner {r
        require(r
            account != address(uniswapV2Router),r
            "ERC20: We can not exclude Uniswap router."r
        );r
        require(!_isExcluded[account], "ERC20: Account is already excluded");r
        if (_reflectionBalance[account] > 0) {r
            _tokenBalance[account] = tokenFromReflection(r
                _reflectionBalance[account]r
            );r
        }r
        _isExcluded[account] = true;r
        _excluded.push(account);r
    }r
r
    function includeAccount(address account) external onlyOwner {r
        require(_isExcluded[account], "ERC20: Account is already included");r
        for (uint256 i = 0; i < _excluded.length; i++) {r
            if (_excluded[i] == account) {r
                _excluded[i] = _excluded[_excluded.length - 1];r
                _tokenBalance[account] = 0;r
                _isExcluded[account] = false;r
                _excluded.pop();r
                break;r
            }r
        }r
    }r
r
    function _approve(r
        address owner,r
        address spender,r
        uint256 amountr
    ) private {r
        require(owner != address(0), "ERC20: approve from the zero address");r
        require(spender != address(0), "ERC20: approve to the zero address");r
r
        _allowances[owner][spender] = amount;r
        emit Approval(owner, spender, amount);r
    }r
r
    function _transfer(r
        address sender,r
        address recipient,r
        uint256 amountr
    ) private {r
        require(sender != address(0), "ERC20: transfer from the zero address");r
        require(recipient != address(0), "ERC20: transfer to the zero address");r
        require(amount > 0, "Transfer amount must be greater than zero");r
r
        require(amount <= maxTxAmount, "Transfer Limit exceeded!");r
r
        uint256 contractTokenBalance = balanceOf(address(this));r
        bool overMinTokenBalance = contractTokenBalance >= minTokensBeforeSwap;r
        if (r
            !inSwapAndLiquify &&r
            overMinTokenBalance &&r
            sender != uniswapV2Pair &&r
            swapAndLiquifyEnabledr
        ) {r
            swapAndLiquify(contractTokenBalance);r
        }r
r
        uint256 transferAmount = amount;r
        uint256 rate = _getReflectionRate();r
r
        if (r
            isTaxActive &&r
            !isTaxless[_msgSender()] &&r
            !isTaxless[recipient] &&r
            !inSwapAndLiquifyr
        ) {r
            transferAmount = collectFee(sender, amount, rate);r
        }r
r
        _reflectionBalance[sender] = _reflectionBalance[sender].sub(r
            amount.mul(rate)r
        );r
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(r
            transferAmount.mul(rate)r
        );r
r
        if (_isExcluded[sender]) {r
            _tokenBalance[sender] = _tokenBalance[sender].sub(amount);r
        }r
        if (_isExcluded[recipient]) {r
            _tokenBalance[recipient] = _tokenBalance[recipient].add(r
                transferAmountr
            );r
        }r
r
        emit Transfer(sender, recipient, transferAmount);r
    }r
r
    function collectFee(r
        address account,r
        uint256 amount,r
        uint256 rater
    ) private returns (uint256) {r
        uint256 transferAmount = amount;r
r
        //@dev tax feer
        if (_taxFee != 0) {r
            uint256 taxFee = amount.mul(_taxFee).div(10**(_feeDecimal + 2));r
            transferAmount = transferAmount.sub(taxFee);r
            _reflectionTotal = _reflectionTotal.sub(taxFee.mul(rate));r
            _taxFeeTotal = _taxFeeTotal.add(taxFee);r
        }r
r
        //@dev liquidity feer
        if (_liquidityFee != 0) {r
            uint256 liquidityFee = amount.mul(_liquidityFee).div(r
                10**(_feeDecimal + 2)r
            );r
            transferAmount = transferAmount.sub(liquidityFee);r
            _reflectionBalance[address(this)] = _reflectionBalance[r
                address(this)r
            ].add(liquidityFee.mul(rate));r
            if (_isExcluded[address(this)]) {r
                _tokenBalance[address(this)] = _tokenBalance[address(this)].add(r
                    liquidityFeer
                );r
            }r
            _liquidityFeeTotal = _liquidityFeeTotal.add(liquidityFee);r
            emit Transfer(account, address(this), liquidityFee);r
        }r
r
        //@dev burn feer
        if (_burnFee != 0) {r
            uint256 burnFee = amount.mul(_burnFee).div(10**(_feeDecimal + 2));r
            transferAmount = transferAmount.sub(burnFee);r
            _tokenTotal = _tokenTotal.sub(burnFee);r
            _reflectionTotal = _reflectionTotal.sub(burnFee.mul(rate));r
            _burnFeeTotal = _burnFeeTotal.add(burnFee);r
            emit Transfer(account, address(0), burnFee);r
        }r
r
        //@dev Marketing feer
        if (_marketingFee != 0) {r
            uint256 marketingFee = amount.mul(_marketingFee).div(r
                10**(_feeDecimal + 2)r
            );r
            transferAmount = transferAmount.sub(marketingFee);r
            _reflectionBalance[marketingWallet] = _reflectionBalance[r
                marketingWalletr
            ].add(marketingFee.mul(rate));r
            if (_isExcluded[marketingWallet]) {r
                _tokenBalance[marketingWallet] = _tokenBalance[marketingWallet]r
                    .add(marketingFee);r
            }r
            _marketingFeeTotal = _marketingFeeTotal.add(marketingFee);r
            emit Transfer(account, marketingWallet, marketingFee);r
        }r
r
        //@dev Charity feer
        if (_charityFee != 0) {r
            uint256 charityFee = amount.mul(_charityFee).div(r
                10**(_feeDecimal + 2)r
            );r
            transferAmount = transferAmount.sub(charityFee);r
            _reflectionBalance[charityWallet] = _reflectionBalance[r
                charityWalletr
            ].add(charityFee.mul(rate));r
            if (_isExcluded[charityWallet]) {r
                _tokenBalance[charityWallet] = _tokenBalance[charityWallet].add(r
                    charityFeer
                );r
            }r
            _charityFeeTotal = _charityFeeTotal.add(charityFee);r
            emit Transfer(account, charityWallet, charityFee);r
        }r
r
        return transferAmount;r
    }r
r
    function _getReflectionRate() private view returns (uint256) {r
        uint256 reflectionSupply = _reflectionTotal;r
        uint256 tokenSupply = _tokenTotal;r
        for (uint256 i = 0; i < _excluded.length; i++) {r
            if (r
                _reflectionBalance[_excluded[i]] > reflectionSupply ||r
                _tokenBalance[_excluded[i]] > tokenSupplyr
            ) return _reflectionTotal.div(_tokenTotal);r
            reflectionSupply = reflectionSupply.sub(r
                _reflectionBalance[_excluded[i]]r
            );r
            tokenSupply = tokenSupply.sub(_tokenBalance[_excluded[i]]);r
        }r
        if (reflectionSupply < _reflectionTotal.div(_tokenTotal))r
            return _reflectionTotal.div(_tokenTotal);r
        return reflectionSupply.div(tokenSupply);r
    }r
r
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {r
        if (contractTokenBalance > maxTxAmount)r
            contractTokenBalance = maxTxAmount;r
        uint256 half = contractTokenBalance.div(2);r
        uint256 otherHalf = contractTokenBalance.sub(half);r
r
        uint256 initialBalance = address(this).balance;r
r
        swapTokensForEth(half);r
r
        uint256 newBalance = address(this).balance.sub(initialBalance);r
r
        addLiquidity(otherHalf, newBalance);r
r
        emit SwapAndLiquify(half, newBalance, otherHalf);r
    }r
r
    function swapTokensForEth(uint256 tokenAmount) private {r
        address[] memory path = new address[](2);r
        path[0] = address(this);r
        path[1] = uniswapV2Router.WETH();r
r
        _approve(address(this), address(uniswapV2Router), tokenAmount);r
r
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(r
            tokenAmount,r
            0,r
            path,r
            address(this),r
            block.timestampr
        );r
    }r
r
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {r
        _approve(address(this), address(uniswapV2Router), tokenAmount);r
r
        uniswapV2Router.addLiquidityETH{value: ethAmount}(r
            address(this),r
            tokenAmount,r
            0,r
            0,r
            address(this),r
            block.timestampr
        );r
    }r
r
    function setPair(address pair) external onlyOwner {r
        uniswapV2Pair = pair;r
    }r
r
    function setMarketingWallet(address account) external onlyOwner {r
        marketingWallet = account;r
    }r
r
    function setCharityWallet(address account) external onlyOwner {r
        charityWallet = account;r
    }r
r
    function setTaxless(address account, bool value) external onlyOwner {r
        isTaxless[account] = value;r
    }r
r
    function setSwapAndLiquifyEnabled(bool enabled) external onlyOwner {r
        swapAndLiquifyEnabled = enabled;r
        SwapAndLiquifyEnabledUpdated(enabled);r
    }r
r
    function setTaxActive(bool value) external onlyOwner {r
        isTaxActive = value;r
    }r
r
    function setTaxFee(uint256 fee) external onlyOwner {r
        require(fee <= 200, "You can't set reflections fee above 2 percent.");r
        _taxFee = fee;r
    }r
r
    function setBurnFee(uint256 fee) external onlyOwner {r
        require(fee <= 200, "You can't set burn fees above 2 percent.");r
        _burnFee = fee;r
    }r
r
    function setLiquidityFee(uint256 fee) external onlyOwner {r
        require(fee <= 200, "You can't set this fee above 2 percent.");r
        _liquidityFee = fee;r
    }r
r
    function setMarketingFee(uint256 fee) external onlyOwner {r
        require(fee <= 200, "You can't set the marketing fee above 2 percent.");r
        _marketingFee = fee;r
    }r
r
    function setCharityFee(uint256 fee) external onlyOwner {r
        require(fee <= 200, "You can't set the charity fee above 2 percent.");r
        _charityFee = fee;r
    }r
r
    function setMaxTxAmount(uint256 amount) external onlyOwner {r
        maxTxAmount = amount;r
    }r
r
    function setMinTokensBeforeSwap(uint256 amount) external onlyOwner {r
        minTokensBeforeSwap = amount;r
    }r
r
    receive() external payable {}r
}r
"
    }
  },
  "settings": {
    "remappings": [],
    "optimizer": {
      "enabled": false,
      "runs": 200
    },
    "evmVersion": "petersburg",
    "libraries": {},
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}