// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title CardVaultToken
 * @notice Fungible token representing proportional economic participation
 *         in a managed vault of authenticated, graded Pokémon cards.
 *
 * @dev The contract does not tokenise individual cards. It tokenises
 *      fractional shares in a pooled off-chain vault. Physical custody
 *      and asset authentication are handled by the issuer off-chain.
 *      Redemption is initiated on-chain (token burn), while settlement
 *      against vault assets is completed off-chain by the custodian.
 */
contract CardVaultToken is ERC20, Ownable, Pausable {

    // ─────────────────────────────────────────────
    //  State variables
    // ─────────────────────────────────────────────

    /// @notice Hard cap on total token supply — limits dilution and
    ///         defines the maximum claim structure over the vault.
    uint256 public immutable maxSupply;

    /// @notice URI pointing to off-chain vault documentation:
    ///         card inventory, PSA grading certificates, valuation
    ///         methodology, and custodian reports.
    string public vaultMetadataURI;

    /// @notice Whether token holders may currently submit redemptions.
    bool public redemptionEnabled;

    /// @notice Net asset value per token in GBP pence (e.g. 150 = £1.50).
    ///         Updated by the owner to reflect current card pool appraisals.
    ///         Used for market pricing discussion — not enforced on-chain.
    uint256 public navPerToken;

    /// @notice Tracks how many primary issuance rounds have occurred.
    ///         Increments each time mint() is called, marking a new
    ///         primary market event. Secondary trading occurs between rounds.
    uint256 public issuanceRound;

    /// @notice Timestamp of the last NAV update.
    ///         Allows holders to assess how stale the current valuation is.
    uint256 public lastNAVUpdate;

    /// @notice Timestamp of the last vault metadata update.
    ///         Allows holders to assess how current the inventory records are.
    uint256 public lastMetadataUpdate;

    // ─────────────────────────────────────────────
    //  Events
    // ─────────────────────────────────────────────

    /// @notice Emitted on primary issuance when vault assets are deposited.
    event TokensMinted(address indexed to, uint256 amount, uint256 round);

    /// @notice Emitted when a holder initiates an exit. Off-chain
    ///         custodian processes the corresponding asset settlement.
    event TokensRedeemed(address indexed from, uint256 amount);

    /// @notice Emitted when the vault metadata reference is updated.
    event VaultMetadataUpdated(string newURI);

    /// @notice Emitted when redemption window is opened or closed.
    event RedemptionStatusChanged(bool enabled);

    /// @notice Emitted when the NAV per token is updated.
    event NAVUpdated(uint256 oldNAV, uint256 newNAV);

    // ─────────────────────────────────────────────
    //  Constructor
    // ─────────────────────────────────────────────

    /**
     * @param _maxSupply        Maximum tokens that can ever be minted.
     *                          Should correspond to total vault capacity.
     * @param _vaultMetadataURI Initial URI for off-chain vault records.
     */
    constructor(
        uint256 _maxSupply,
        string memory _vaultMetadataURI
    )
        ERC20("Pokemon Card Vault Token", "PCVT")
        Ownable(msg.sender)
    {
        require(_maxSupply > 0, "Max supply must be > 0");
        maxSupply          = _maxSupply;
        vaultMetadataURI   = _vaultMetadataURI;
        redemptionEnabled  = false;
    }

    // ─────────────────────────────────────────────
    //  Owner-only: issuance
    // ─────────────────────────────────────────────

    /**
     * @notice Mint new tokens to represent assets deposited into the vault.
     * @dev    Only the owner (vault operator) may issue tokens.
     *         Supply cannot exceed maxSupply, preventing dilution beyond
     *         the defined cap.
     * @param to     Recipient of the newly issued tokens.
     * @param amount Number of tokens (in smallest unit, 18 decimals).
     */
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0),                    "Mint to zero address");
        require(totalSupply() + amount <= maxSupply, "Exceeds max supply");
        issuanceRound += 1;
        _mint(to, amount);
        emit TokensMinted(to, amount, issuanceRound);
    }

    // ─────────────────────────────────────────────
    //  Redemption
    // ─────────────────────────────────────────────

    /**
     * @notice Initiate an exit from the vault by burning tokens.
     * @dev    Burning is on-chain; the matching fiat or stablecoin
     *         settlement against vault card sales is handled off-chain
     *         by the custodian/issuer after observing this event.
     * @param amount Number of tokens the caller wishes to redeem.
     */
    function redeem(uint256 amount) external whenNotPaused {
        require(redemptionEnabled,            "Redemptions currently closed");
        require(amount > 0,                   "Amount must be > 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _burn(msg.sender, amount);
        emit TokensRedeemed(msg.sender, amount);
    }

    // ─────────────────────────────────────────────
    //  Owner-only: controls
    // ─────────────────────────────────────────────

    /**
     * @notice Pause all token transfers and redemptions.
     * @dev    Use in emergencies: smart contract incident, fraud
     *         suspicion, or regulatory/custody problem. Introduces
     *         centralisation risk — discussed in risk analysis.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Resume normal operations after a pause.
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Open or close the redemption window.
     * @param _enabled True to allow redemptions, false to suspend them.
     */
    function setRedemptionEnabled(bool _enabled) external onlyOwner {
        redemptionEnabled = _enabled;
        emit RedemptionStatusChanged(_enabled);
    }

    /**
     * @notice Update the net asset value per token.
     * @dev    NAV is expressed in GBP pence for simplicity (e.g. 150 = £1.50).
     *         This is an off-chain appraisal figure pushed on-chain for
     *         transparency. It does not automatically affect transfer prices.
     * @param _nav New NAV per token in pence.
     */
    function updateNAV(uint256 _nav) external onlyOwner {
        require(_nav > 0, "NAV must be > 0");
        uint256 oldNAV = navPerToken;
        navPerToken = _nav;
        lastNAVUpdate = block.timestamp;
        emit NAVUpdated(oldNAV, _nav);
    }

    /**
     * @notice Update the URI pointing to off-chain vault documentation.
     * @dev    The referenced document must include PSA/BGS certificate
     *         numbers, grades, and certificate links for every card in
     *         the vault. lastMetadataUpdate is recorded on-chain so
     *         holders can assess how current the inventory records are.
     * @param newURI New metadata URI (e.g. IPFS or custodian portal).
     */
    function setVaultMetadataURI(string calldata newURI) external onlyOwner {
        vaultMetadataURI   = newURI;
        lastMetadataUpdate = block.timestamp;
        emit VaultMetadataUpdated(newURI);
    }

    // ─────────────────────────────────────────────
    //  Transfer guard
    // ─────────────────────────────────────────────

    /**
     * @dev Hook called before every transfer, mint, and burn.
     *      Blocks all token movements while the contract is paused.
     *      Transfers are otherwise permissionless — KYC/AML compliance
     *      is enforced off-chain at the platform and custodian level,
     *      preserving on-chain liquidity for secondary market trading.
     *      Standard approve() and allowance() functions are inherited
     *      from ERC20, enabling delegated transfers for DEX and
     *      protocol integrations.
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._update(from, to, amount);
    }

    /**
     * @notice Disabled. The vault always requires an active operator
     *         to mint, update NAV, and process redemptions. Permanently
     *         removing ownership would render the contract unmanageable.
     */
    function renounceOwnership() public pure override {
        revert("Renouncing ownership is disabled");
    }
}
