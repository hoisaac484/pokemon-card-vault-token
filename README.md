# Pokémon Card Vault Token (PCVT)

An ERC-20 smart contract representing fungible fractional ownership in a custodial vault of professionally graded Pokémon trading cards. Deployed on the Ethereum Sepolia testnet as part of an asset tokenisation design project.

---

## Contract Details

| Field | Value |
|---|---|
| **Token Name** | Pokemon Card Vault Token |
| **Symbol** | PCVT |
| **Decimals** | 18 |
| **Network** | Ethereum Sepolia Testnet |
| **Contract Address** | `0x423743e4176da5c10505d32a42d41052ba182d0b` |
| **Solidity Version** | ^0.8.20 |
| **Standard** | ERC-20 (OpenZeppelin) |

---

## Overview

PCVT does not tokenise individual Pokémon cards. Instead, it tokenises **proportional economic participation in a managed vault** of authenticated, graded cards. Holders own a pro-rata share of the pooled portfolio's net asset value — not rights to any specific card.

The chain of logic is:

```
Physical graded cards → Custodial vault → ERC-20 token shares (PCVT)
```

Settlement of physical assets and KYC/AML compliance are handled **off-chain** by the vault operator. The smart contract manages issuance, supply rules, redemption signalling, and on-chain transparency.

---

## Features

### Supply Model
- **Capped adjustable supply** — `maxSupply` is set at deployment and is immutable
- Tokens are minted in discrete **issuance rounds** as cards are added to the vault
- Each `mint()` call increments `issuanceRound`, creating an auditable primary market record

### NAV Transparency
- `navPerToken` publishes the current appraised value per token on-chain (in GBP pence)
- Updated by the vault operator following card reappraisals
- Informational only — does not enforce secondary market prices

### Redemption
- `redeem()` burns tokens on-chain, signalling an exit request
- Settlement (cash payout based on NAV) is processed off-chain by the custodian
- Gated by `redemptionEnabled` flag — operator controls when redemption windows are open

### Emergency Controls
- `pause()` / `unpause()` freeze all transfers and redemptions
- Used in scenarios such as smart contract incidents, fraud suspicion, or regulatory action

### Metadata URI
- `vaultMetadataURI` points to off-chain vault documentation
- Includes card inventory, PSA grading certificates, and valuation methodology
- Updatable without redeploying the contract

---

## Contract Functions

### Owner-only

| Function | Description |
|---|---|
| `mint(address to, uint256 amount)` | Issue new tokens against vault deposits |
| `updateNAV(uint256 _nav)` | Update net asset value per token in GBP pence |
| `setRedemptionEnabled(bool)` | Open or close the redemption window |
| `setVaultMetadataURI(string)` | Update the off-chain vault documentation URI |
| `pause()` / `unpause()` | Emergency freeze / resume of all transfers |

### Public

| Function | Description |
|---|---|
| `redeem(uint256 amount)` | Burn tokens to initiate a redemption request |
| `transfer(address, uint256)` | Standard ERC-20 transfer |
| `approve(address, uint256)` | Standard ERC-20 approval |
| `transferFrom(address, address, uint256)` | Standard ERC-20 delegated transfer |

### View

| Variable | Description |
|---|---|
| `maxSupply` | Hard cap on total token supply |
| `navPerToken` | Current NAV per token in GBP pence |
| `issuanceRound` | Number of primary issuance rounds completed |
| `redemptionEnabled` | Whether redemptions are currently open |
| `vaultMetadataURI` | URI pointing to off-chain vault records |

---

## Events

| Event | Emitted when |
|---|---|
| `TokensMinted(address, uint256, uint256)` | Tokens are minted (includes round number) |
| `TokensRedeemed(address, uint256)` | A holder initiates a redemption |
| `NAVUpdated(uint256, uint256)` | NAV per token is updated |
| `VaultMetadataUpdated(string)` | Vault documentation URI is updated |
| `RedemptionStatusChanged(bool)` | Redemption window opened or closed |

---

## Lifecycle

```
1. PRIMARY ISSUANCE
   Cards appraised and deposited into vault
   → operator calls mint() → TokensMinted event emitted
   → issuanceRound increments
   → investors receive PCVT tokens

2. SECONDARY MARKET
   Holders trade PCVT peer-to-peer or via DEX (e.g. Uniswap)
   → price discovery around NAV
   → operator updates navPerToken after reappraisals

3. REDEMPTION
   Holder calls redeem() → tokens burned → TokensRedeemed event
   → custodian observes event off-chain
   → cash settlement paid based on NAV per token
```

---

## Deployment

The contract is deployed using [Remix IDE](https://remix.ethereum.org) with OpenZeppelin imports resolved automatically.

**Constructor arguments:**
- `_maxSupply` — total token cap in smallest unit (18 decimals). Example: `1000000000000000000000000` = 1,000,000 PCVT
- `_vaultMetadataURI` — URI pointing to initial vault documentation

**Dependencies (resolved via npm in Remix):**
- `@openzeppelin/contracts/token/ERC20/ERC20.sol`
- `@openzeppelin/contracts/access/Ownable.sol`
- `@openzeppelin/contracts/utils/Pausable.sol`

---

## Design Decisions

**Why ERC-20 and not ERC-721?**
Holders own a proportional share of the pooled vault, not rights to any individual card. All tokens are economically equivalent — one PCVT represents the same pro-rata claim as any other. This standardisation requires fungibility, making ERC-20 the correct standard.

**Why is KYC off-chain?**
An on-chain whitelist would restrict secondary market liquidity by preventing tokens from being received by any address not pre-approved by the operator. KYC and AML compliance is instead enforced at the platform level during primary issuance, keeping on-chain transfers permissionless and compatible with DEX infrastructure.

**Why capped supply over fixed supply?**
A fixed supply minted at deployment assumes the vault is closed-end and static. A capped adjustable supply allows the vault to expand as new cards are acquired, with each issuance round representing a discrete primary market event — a more realistic model for a growing collectibles portfolio.

---

## Disclaimer

This contract is deployed on a testnet for academic purposes only. It does not constitute a financial instrument, investment offering, or regulated product. No real assets are held in any vault associated with this deployment.
