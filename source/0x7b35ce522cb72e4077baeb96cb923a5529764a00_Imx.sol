{{
  "language": "Solidity",
  "sources": {
    "/C/Users/simor/Desktop/imx/contracts/Imx.sol": {
      "content": "// COPIED FROM https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.solr
// Copyright 2020 Compound Labs, Inc.r
// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:r
// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.r
// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.r
// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.r
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.r
r
pragma solidity =0.6.6;r
pragma experimental ABIEncoderV2;r
r
contract Imx {r
    /// @notice EIP-20 token name for this tokenr
    string public constant name = "Impermax";r
r
    /// @notice EIP-20 token symbol for this tokenr
    string public constant symbol = "IMX";r
r
    /// @notice EIP-20 token decimals for this tokenr
    uint8 public constant decimals = 18;r
r
    /// @notice Total number of tokens in circulationr
    uint public constant totalSupply = 100_000_000e18; // 100 million Imxr
r
    /// @notice Allowance amounts on behalf of othersr
    mapping (address => mapping (address => uint96)) internal allowances;r
r
    /// @notice Official record of token balances for each accountr
    mapping (address => uint96) internal balances;r
r
    /// @notice A record of each accounts delegater
    mapping (address => address) public delegates;r
r
    /// @notice A checkpoint for marking number of votes from a given blockr
    struct Checkpoint {r
        uint32 fromBlock;r
        uint96 votes;r
    }r
r
    /// @notice A record of votes checkpoints for each account, by indexr
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;r
r
    /// @notice The number of checkpoints for each accountr
    mapping (address => uint32) public numCheckpoints;r
r
    /// @notice The EIP-712 typehash for the contract's domainr
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");r
r
    /// @notice The EIP-712 typehash for the delegation struct used by the contractr
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");r
r
    /// @notice A record of states for signing / validating signaturesr
    mapping (address => uint) public nonces;r
r
    /// @notice An event thats emitted when an account changes its delegater
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);r
r
    /// @notice An event thats emitted when a delegate account's vote balance changesr
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);r
r
    /// @notice The standard EIP-20 transfer eventr
    event Transfer(address indexed from, address indexed to, uint256 amount);r
r
    /// @notice The standard EIP-20 approval eventr
    event Approval(address indexed owner, address indexed spender, uint256 amount);r
r
    /**r
     * @notice Construct a new Imx tokenr
     * @param account The initial account to grant all the tokensr
     */r
    constructor(address account) public {r
        balances[account] = uint96(totalSupply);r
        emit Transfer(address(0), account, totalSupply);r
    }r
r
    /**r
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`r
     * @param account The address of the account holding the fundsr
     * @param spender The address of the account spending the fundsr
     * @return The number of tokens approvedr
     */r
    function allowance(address account, address spender) external view returns (uint) {r
        return allowances[account][spender];r
    }r
r
    /**r
     * @notice Approve `spender` to transfer up to `amount` from `src`r
     * @dev This will overwrite the approval amount for `spender`r
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)r
     * @param spender The address of the account which may transfer tokensr
     * @param rawAmount The number of tokens that are approved (2^256-1 means infinite)r
     * @return Whether or not the approval succeededr
     */r
    function approve(address spender, uint rawAmount) external returns (bool) {r
        uint96 amount;r
        if (rawAmount == uint(-1)) {r
            amount = uint96(-1);r
        } else {r
            amount = safe96(rawAmount, "Imx::approve: amount exceeds 96 bits");r
        }r
r
        allowances[msg.sender][spender] = amount;r
r
        emit Approval(msg.sender, spender, amount);r
        return true;r
    }r
tr
    /**r
     * @notice Get the number of tokens held by the `account`r
     * @param account The address of the account to get the balance ofr
     * @return The number of tokens heldr
     */r
    function balanceOf(address account) external view returns (uint) {r
        return balances[account];r
    }r
r
    /**r
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`r
     * @param dst The address of the destination accountr
     * @param rawAmount The number of tokens to transferr
     * @return Whether or not the transfer succeededr
     */r
    function transfer(address dst, uint rawAmount) external returns (bool) {r
        uint96 amount = safe96(rawAmount, "Imx::transfer: amount exceeds 96 bits");r
        _transferTokens(msg.sender, dst, amount);r
        return true;r
    }r
r
    /**r
     * @notice Transfer `amount` tokens from `src` to `dst`r
     * @param src The address of the source accountr
     * @param dst The address of the destination accountr
     * @param rawAmount The number of tokens to transferr
     * @return Whether or not the transfer succeededr
     */r
    function transferFrom(address src, address dst, uint rawAmount) external returns (bool) {r
        address spender = msg.sender;r
        uint96 spenderAllowance = allowances[src][spender];r
        uint96 amount = safe96(rawAmount, "Imx::approve: amount exceeds 96 bits");r
r
        if (spender != src && spenderAllowance != uint96(-1)) {r
            uint96 newAllowance = sub96(spenderAllowance, amount, "Imx::transferFrom: transfer amount exceeds spender allowance");r
            allowances[src][spender] = newAllowance;r
r
            emit Approval(src, spender, newAllowance);r
        }r
r
        _transferTokens(src, dst, amount);r
        return true;r
    }r
r
    /**r
     * @notice Delegate votes from `msg.sender` to `delegatee`r
     * @param delegatee The address to delegate votes tor
     */r
    function delegate(address delegatee) public {r
        return _delegate(msg.sender, delegatee);r
    }r
r
    /**r
     * @notice Delegates votes from signatory to `delegatee`r
     * @param delegatee The address to delegate votes tor
     * @param nonce The contract state required to match the signaturer
     * @param expiry The time at which to expire the signaturer
     * @param v The recovery byte of the signaturer
     * @param r Half of the ECDSA signature pairr
     * @param s Half of the ECDSA signature pairr
     */r
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {r
        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this)));r
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));r
        bytes32 digest = keccak256(abi.encodePacked("x19x01", domainSeparator, structHash));r
        address signatory = ecrecover(digest, v, r, s);r
        require(signatory != address(0), "Imx::delegateBySig: invalid signature");r
        require(nonce == nonces[signatory]++, "Imx::delegateBySig: invalid nonce");r
        require(now <= expiry, "Imx::delegateBySig: signature expired");r
        return _delegate(signatory, delegatee);r
    }r
r
    /**r
     * @notice Gets the current votes balance for `account`r
     * @param account The address to get votes balancer
     * @return The number of current votes for `account`r
     */r
    function getCurrentVotes(address account) external view returns (uint96) {r
        uint32 nCheckpoints = numCheckpoints[account];r
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;r
    }r
r
    /**r
     * @notice Determine the prior number of votes for an account as of a block numberr
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.r
     * @param account The address of the account to checkr
     * @param blockNumber The block number to get the vote balance atr
     * @return The number of votes the account had as of the given blockr
     */r
    function getPriorVotes(address account, uint blockNumber) public view returns (uint96) {r
        require(blockNumber < block.number, "Imx::getPriorVotes: not yet determined");r
r
        uint32 nCheckpoints = numCheckpoints[account];r
        if (nCheckpoints == 0) {r
            return 0;r
        }r
r
        // First check most recent balancer
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {r
            return checkpoints[account][nCheckpoints - 1].votes;r
        }r
r
        // Next check implicit zero balancer
        if (checkpoints[account][0].fromBlock > blockNumber) {r
            return 0;r
        }r
r
        uint32 lower = 0;r
        uint32 upper = nCheckpoints - 1;r
        while (upper > lower) {r
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflowr
            Checkpoint memory cp = checkpoints[account][center];r
            if (cp.fromBlock == blockNumber) {r
                return cp.votes;r
            } else if (cp.fromBlock < blockNumber) {r
                lower = center;r
            } else {r
                upper = center - 1;r
            }r
        }r
        return checkpoints[account][lower].votes;r
    }r
r
    function _delegate(address delegator, address delegatee) internal {r
        address currentDelegate = delegates[delegator];r
        uint96 delegatorBalance = balances[delegator];r
        delegates[delegator] = delegatee;r
r
        emit DelegateChanged(delegator, currentDelegate, delegatee);r
r
        _moveDelegates(currentDelegate, delegatee, delegatorBalance);r
    }r
r
    function _transferTokens(address src, address dst, uint96 amount) internal {r
        require(src != address(0), "Imx::_transferTokens: cannot transfer from the zero address");r
        require(dst != address(0), "Imx::_transferTokens: cannot transfer to the zero address");r
r
        balances[src] = sub96(balances[src], amount, "Imx::_transferTokens: transfer amount exceeds balance");r
        balances[dst] = add96(balances[dst], amount, "Imx::_transferTokens: transfer amount overflows");r
        emit Transfer(src, dst, amount);r
r
        _moveDelegates(delegates[src], delegates[dst], amount);r
    }r
r
    function _moveDelegates(address srcRep, address dstRep, uint96 amount) internal {r
        if (srcRep != dstRep && amount > 0) {r
            if (srcRep != address(0)) {r
                uint32 srcRepNum = numCheckpoints[srcRep];r
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;r
                uint96 srcRepNew = sub96(srcRepOld, amount, "Imx::_moveVotes: vote amount underflows");r
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);r
            }r
r
            if (dstRep != address(0)) {r
                uint32 dstRepNum = numCheckpoints[dstRep];r
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;r
                uint96 dstRepNew = add96(dstRepOld, amount, "Imx::_moveVotes: vote amount overflows");r
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);r
            }r
        }r
    }r
r
    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint96 oldVotes, uint96 newVotes) internal {r
      uint32 blockNumber = safe32(block.number, "Imx::_writeCheckpoint: block number exceeds 32 bits");r
r
      if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {r
          checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;r
      } else {r
          checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);r
          numCheckpoints[delegatee] = nCheckpoints + 1;r
      }r
r
      emit DelegateVotesChanged(delegatee, oldVotes, newVotes);r
    }r
r
    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {r
        require(n < 2**32, errorMessage);r
        return uint32(n);r
    }r
r
    function safe96(uint n, string memory errorMessage) internal pure returns (uint96) {r
        require(n < 2**96, errorMessage);r
        return uint96(n);r
    }r
r
    function add96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {r
        uint96 c = a + b;r
        require(c >= a, errorMessage);r
        return c;r
    }r
r
    function sub96(uint96 a, uint96 b, string memory errorMessage) internal pure returns (uint96) {r
        require(b <= a, errorMessage);r
        return a - b;r
    }r
r
    function getChainId() internal pure returns (uint) {r
        uint256 chainId;r
        assembly { chainId := chainid() }r
        return chainId;r
    }r
}"
    }
  },
  "settings": {
    "remappings": [],
    "optimizer": {
      "enabled": true,
      "runs": 999999
    },
    "evmVersion": "istanbul",
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