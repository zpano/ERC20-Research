{"iBASE.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.3;\nimport \"./iDAO.sol\";\ninterface iBASE {\n    function DAO() external view returns (iDAO);\n    function secondsPerEra() external view returns (uint256);\n    function changeDAO(address) external returns(bool);\n    function setParams(uint256, uint256) external;\n    function flipEmissions() external returns(bool);\n}"},"iBASEv1.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.3;\ninterface iBASEv1 {\n    function transferTo(address,uint256) external returns(bool);\n}"},"iBEP20.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.3;\ninterface iBEP20 {\n    function name() external view returns (string memory);\n    function symbol() external view returns (string memory);\n    function decimals() external view returns (uint8);\n    function totalSupply() external view returns (uint256);\n    function balanceOf(address account) external view returns (uint256);\n    function transfer(address, uint256) external returns (bool);\n    function allowance(address owner, address spender) external view returns (uint256);\n    function approve(address, uint256) external returns (bool);\n    function transferFrom(address, address, uint256) external returns (bool);\n    function burn(uint) external;\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"},"iBEP677.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.3;\n\ninterface iBEP677 {\n function onTokenApproval(address token, uint amount, address member,bytes calldata data) external;\n function onTokenTransfer(address token, uint amount, address member,bytes calldata data) external;\n}"},"iDAO.sol":{"content":"// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.3;\ninterface iDAO {\n    function ROUTER() external view returns(address);\n    function BASE() external view returns(address);\n    function UTILS() external view returns(address);\n    function DAO() external view returns (address);\n    function RESERVE() external view returns(address);\n    function BOND() external view returns (address);\n    function SYNTHFACTORY() external view returns(address);\n    function POOLFACTORY() external view returns(address);\n    function depositForMember(address pool, uint256 amount, address member) external;\n}"},"iUTILS.sol":{"content":"//SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.3;\ninterface iUTILS {\n    function calcPart(uint bp, uint total) external pure returns (uint part);\n    function calcShare(uint part, uint total, uint amount) external pure returns (uint share);\n    function calcSpotValueInBase(address, uint) external pure returns (uint);\n    function getFeeOnTransfer(uint256 totalSupply, uint256 maxSupply) external view returns(uint);\n    function calcSwapValueInBase(address pool, uint256 amount) external view returns (uint256 value);\n    function getPoolShareWeight(address token, uint units)external view returns(uint weight);\n}"},"Sparta.sol":{"content":"\n// SPDX-License-Identifier: UNLICENSED\npragma solidity 0.8.3;\nimport \"./iBEP20.sol\";\nimport \"./iDAO.sol\";\nimport \"./iBASE.sol\";\nimport \"./iBASEv1.sol\"; \nimport \"./iUTILS.sol\";\nimport \"./iBEP677.sol\"; \n\n    //======================================SPARTA=========================================//\ncontract Sparta is iBEP20 {\n\n    // BEP-20 Parameters\n    string public constant override name = \u0027Spartan Protocol Token V2\u0027;\n    string public constant override symbol = \u0027SPARTA\u0027;\n    uint8 public constant override decimals = 18;\n    uint256 public override totalSupply;\n\n    // BEP-20 Mappings\n    mapping(address =\u003e uint256) private _balances;\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\n\n    // Parameters\n    bool public emitting;\n    bool public minting;\n    bool private savedSpartans;\n    uint256 public feeOnTransfer;\n    \n    uint256 public emissionCurve;\n    uint256 private _100m;\n    uint256 public maxSupply;\n\n    uint256 public secondsPerEra;\n    uint256 public nextEraTime;\n\n    address public DAO;\n    address public DEPLOYER;\n    address public BASEv1;\n\n    event NewEra(uint256 nextEraTime, uint256 emission);\n\n    // Only DAO can execute\n    modifier onlyDAO() {\n        require(msg.sender == DAO || msg.sender == DEPLOYER, \"!DAO\");\n        _;\n    }\n\n    //=====================================CREATION=========================================//\n    // Constructor\n    constructor(address _baseV1) {\n        _100m = 100 * 10**6 * 10**decimals; // 100m\n        maxSupply = 300 * 10**6 * 10**decimals; // 300m\n        emissionCurve = 2048;\n        BASEv1 = _baseV1;\n        secondsPerEra =  86400; // 1 day\n        nextEraTime = block.timestamp + secondsPerEra;\n        DEPLOYER = msg.sender;\n    }\n\n    //========================================iBEP20=========================================//\n    function balanceOf(address account) public view override returns (uint256) {\n        return _balances[account];\n    }\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\n        return _allowances[owner][spender];\n    }\n    // iBEP20 Transfer function\n    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {\n        _transfer(msg.sender, recipient, amount);\n        return true;\n    }\n    // iBEP20 Approve, change allowance functions\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\n        _approve(msg.sender, spender, amount);\n        return true;\n    }\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\n        _approve(msg.sender, spender, _allowances[msg.sender][spender]+(addedValue));\n        return true;\n    }\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\n        uint256 currentAllowance = _allowances[msg.sender][spender];\n        require(currentAllowance \u003e= subtractedValue, \"allowance err\");\n        _approve(msg.sender, spender, currentAllowance - subtractedValue);\n        return true;\n    }\n\n     function _approve( address owner, address spender, uint256 amount) internal virtual {\n        require(owner != address(0), \"sender\");\n        require(spender != address(0), \"spender\");\n        if (_allowances[owner][spender] \u003c type(uint256).max) { // No need to re-approve if already max\n            _allowances[owner][spender] = amount;\n            emit Approval(owner, spender, amount);\n        }\n    }\n    \n    // iBEP20 TransferFrom function\n     function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {\n        _transfer(sender, recipient, amount);\n        // Unlimited approval (saves an SSTORE)\n        if (_allowances[sender][msg.sender] \u003c type(uint256).max) {\n            uint256 currentAllowance = _allowances[sender][msg.sender];\n            require(currentAllowance \u003e= amount, \"allowance err\");\n            _approve(sender, msg.sender, currentAllowance - amount);\n        }\n        return true;\n    }\n\n    //iBEP677 approveAndCall\n    function approveAndCall(address recipient, uint amount, bytes calldata data) external returns (bool) {\n      _approve(msg.sender, recipient, type(uint256).max); // Give recipient max approval\n      iBEP677(recipient).onTokenApproval(address(this), amount, msg.sender, data); // Amount is passed thru to recipient\n      return true;\n     }\n\n      //iBEP677 transferAndCall\n    function transferAndCall(address recipient, uint amount, bytes calldata data) external returns (bool) {\n      _transfer(msg.sender, recipient, amount);\n      iBEP677(recipient).onTokenTransfer(address(this), amount, msg.sender, data); // Amount is passed thru to recipient \n      return true;\n     }\n\n\n    // Internal transfer function\n    function _transfer(address sender, address recipient, uint256 amount) internal virtual {\n        require(sender != address(0), \"transfer err\");\n        require(recipient != address(this), \"recipient\"); // Don\u0027t allow transfers here\n        uint256 senderBalance = _balances[sender];\n        require(senderBalance \u003e= amount, \"balance err\");\n        uint _fee = iUTILS(UTILS()).calcPart(feeOnTransfer, amount);   // Critical functionality                                                      \n        if(_fee \u003c= amount){                // Stops reverts if UTILS corrupted           \n            amount -= _fee;\n            _burn(sender, _fee);\n        }\n        _balances[sender] -= amount;\n        _balances[recipient] += amount;\n        emit Transfer(sender, recipient, amount);\n        _checkEmission();\n    }\n\n    // Internal mint (upgrading and daily emissions)\n    function _mint(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"address err\");\n        totalSupply += amount;\n        require(totalSupply \u003c= maxSupply, \"Maxxed\");\n        _balances[account] += amount;\n        emit Transfer(address(0), account, amount);\n    }\n    // Burn supply\n    function burn(uint256 amount) public virtual override {\n        _burn(msg.sender, amount);\n    }\n    function burnFrom(address account, uint256 amount) public virtual {  \n        uint256 decreasedAllowance = allowance(account, msg.sender) - (amount);\n        _approve(account, msg.sender, decreasedAllowance); \n        _burn(account, amount);\n    }\n    function _burn(address account, uint256 amount) internal virtual {\n        require(account != address(0), \"address err\");\n        require(_balances[account] \u003e= amount, \"balance err\");\n        _balances[account] -= amount;\n        totalSupply -= amount;\n        emit Transfer(account, address(0), amount);\n    }\n\n\n    //=========================================DAO=========================================//\n    // Can start\n    function flipEmissions() external onlyDAO {\n        emitting = !emitting;\n    }\n     // Can stop\n    function flipMinting() external onlyDAO {\n        minting = !minting;\n    }\n    // Can set params\n    function setParams(uint256 newTime, uint256 newCurve) external onlyDAO {\n        secondsPerEra = newTime;\n        emissionCurve = newCurve;\n    }\n    function saveFallenSpartans(address _savedSpartans, uint256 _saveAmount) external onlyDAO{\n        require(!savedSpartans, \u0027spartans saved\u0027); // only one time\n        savedSpartans = true;\n        _mint(_savedSpartans, _saveAmount);\n    }\n    // Can change DAO\n    function changeDAO(address newDAO) external onlyDAO {\n        require(newDAO != address(0), \"address err\");\n        DAO = newDAO;\n    }\n    // Can purge DAO\n    function purgeDAO() external onlyDAO {\n        DAO = address(0);\n    }\n    // Can purge DEPLOYER\n    function purgeDeployer() public onlyDAO {\n        DEPLOYER = address(0);\n    }\n\n   //======================================EMISSION========================================//\n    // Internal - Update emission function\n    function _checkEmission() private {\n        if ((block.timestamp \u003e= nextEraTime) \u0026\u0026 emitting) {    // If new Era and allowed to emit                      \n            nextEraTime = block.timestamp + secondsPerEra; // Set next Era time\n            uint256 _emission = getDailyEmission(); // Get Daily Dmission\n            _mint(RESERVE(), _emission); // Mint to the RESERVE Address\n            feeOnTransfer = iUTILS(UTILS()).getFeeOnTransfer(totalSupply, maxSupply); \n            if (feeOnTransfer \u003e 500) {\n                feeOnTransfer = 500; // Max 5% FoT\n            } \n            emit NewEra(nextEraTime, _emission); // Emit Event\n        }\n    }\n    // Calculate Daily Emission\n    function getDailyEmission() public view returns (uint256) {\n        uint _adjustedCap;\n        if(totalSupply \u003c= _100m){ // If less than 100m, then adjust cap down\n            _adjustedCap = (maxSupply * totalSupply)/(_100m); // 300m * 50m / 100m = 300m * 50% = 150m\n        } else {\n            _adjustedCap = maxSupply;  // 300m\n        }\n        return (_adjustedCap - totalSupply) / (emissionCurve); // outstanding / 2048 \n    }\n\n    //==========================================Minting============================================//\n    function upgrade() external {\n        uint amount = iBEP20(BASEv1).balanceOf(msg.sender); //Get balance of sender\n        require(iBASEv1(BASEv1).transferTo(address(this), amount)); //Transfer balance from sender\n        iBEP20(BASEv1).burn(amount); //burn balance \n        _mint(msg.sender, amount); // 1:1\n    }\n\n    function mintFromDAO(uint256 amount, address recipient) external onlyDAO {\n        require(amount \u003c= 5 * 10**6 * 10**decimals, \u0027!5m\u0027); //5m at a time\n        if(minting \u0026\u0026 (totalSupply \u003c=  150 * 10**6 * 10**decimals)){ // Only can mint up to 150m\n             _mint(recipient, amount); \n        }\n    }\n\n    //======================================HELPERS========================================//\n    // Helper Functions\n    function UTILS() internal view returns(address){\n        return iDAO(DAO).UTILS();\n    }\n    function RESERVE() internal view returns(address){\n        return iDAO(DAO).RESERVE(); \n    }\n\n}"}}