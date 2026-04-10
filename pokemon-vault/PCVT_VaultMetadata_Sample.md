# Pokémon Card Vault Token (PCVT) — Vault Metadata

**Document type:** vaultMetadataURI reference  
**Issue date:** 10 April 2026  
**Document version:** 1.0  
**Network:** Ethereum Sepolia Testnet

This document is published at the address stored in the `vaultMetadataURI` variable of the PCVT smart contract. It constitutes the authoritative off-chain record of vault composition, card authentication, and valuation methodology. Token holders should reference this document when assessing the backing of their PCVT holdings.

---

## 1. Contract Reference

| Field | Value |
|---|---|
| Contract address | `0x423743e4176da5c10505d32a42d41052ba182d0b` |
| Network | Ethereum Sepolia Testnet |
| Token name | Pokemon Card Vault Token |
| Token symbol | PCVT |
| Decimals | 18 |
| Max supply | 1,000,000 PCVT |
| Issuance round | 1 |
| Current navPerToken | 110 GBP pence (£1.10 per token) |
| Last NAV update | 10 April 2026 |
| Last metadata update | 10 April 2026 |

---

## 2. Vault Card Inventory

All cards meet the minimum PSA 8 quality threshold defined in the token design.

| # | Card name | Set | Year | Grade | PSA cert no. | Valuation (GBP) |
|---|---|---|---|---|---|---|
| 1 | Charizard (Holo) | Base Set | 1999 | PSA 9 | 45678901 | £28,500 |
| 2 | Blastoise (Holo) | Base Set | 1999 | PSA 9 | 45678902 | £9,200 |
| 3 | Venusaur (Holo) | Base Set | 1999 | PSA 8 | 45678903 | £5,800 |
| 4 | Charizard (Holo) | Base Set 2 | 2000 | PSA 9 | 45678904 | £12,000 |
| 5 | Pikachu (Promo) | Wizards Black Star | 1999 | PSA 10 | 45678905 | £7,400 |
| 6 | Lugia (Holo) | Neo Genesis | 2000 | PSA 9 | 45678906 | £6,100 |
| 7 | Ho-Oh (Holo) | Neo Revelation | 2001 | PSA 8 | 45678907 | £3,200 |
| 8 | Mewtwo (Holo) | Base Set | 1999 | PSA 9 | 45678908 | £4,800 |
| | | | | | **Total vault value** | **£77,000** |

---

## 3. Authentication and Grading

All cards have been independently authenticated and graded by the Professional Sports Authenticator (PSA). Certificate links allow any token holder to verify the grade and authenticity of each card directly on the PSA registry.

| # | Card name | PSA cert no. | Grade | PSA registry link |
|---|---|---|---|---|
| 1 | Charizard (Holo) Base Set | 45678901 | PSA 9 | https://www.psacard.com/cert/45678901 |
| 2 | Blastoise (Holo) Base Set | 45678902 | PSA 9 | https://www.psacard.com/cert/45678902 |
| 3 | Venusaur (Holo) Base Set | 45678903 | PSA 8 | https://www.psacard.com/cert/45678903 |
| 4 | Charizard (Holo) Base Set 2 | 45678904 | PSA 9 | https://www.psacard.com/cert/45678904 |
| 5 | Pikachu (Promo) WBS | 45678905 | PSA 10 | https://www.psacard.com/cert/45678905 |
| 6 | Lugia (Holo) Neo Genesis | 45678906 | PSA 9 | https://www.psacard.com/cert/45678906 |
| 7 | Ho-Oh (Holo) Neo Revelation | 45678907 | PSA 8 | https://www.psacard.com/cert/45678907 |
| 8 | Mewtwo (Holo) Base Set | 45678908 | PSA 9 | https://www.psacard.com/cert/45678908 |

---

## 4. Valuation Methodology

Card valuations are determined using the following methodology and updated following each appraisal cycle. The aggregate vault value is used to calculate `navPerToken`, which is then updated in the smart contract via `updateNAV()`.

| Field | Detail |
|---|---|
| Appraisal frequency | Quarterly, or following a material market event |
| Primary price source | PWCC Marketplace auction results (trailing 90 days) |
| Secondary source | eBay completed sales for equivalent PSA grade and set |
| Valuation basis | Median of comparable sales within the same grade tier |
| Currency | GBP — converted from USD at Bank of England spot rate on appraisal date |
| NAV calculation | Total vault value / circulating token supply |
| Rounding | NAV expressed in GBP pence, rounded down to nearest pence |

---

## 5. Custody and Insurance

Physical cards are stored in a professionally managed third-party custodial facility. The vault operator retains certificates of insurance and custody receipts, available to verified token holders upon written request.

| Field | Detail |
|---|---|
| Custodian | PCVT Vault Operations Ltd (sample entity) |
| Storage facility | Secured climate-controlled vault, London, UK |
| Insurance coverage | £150,000 aggregate — all-risk collectibles policy |
| Insurer | Sample Insurance Co. — Policy ref: SIC-2024-PCVT-001 |
| Last audit | 10 April 2026 |
| Audit firm | Independent collectibles assessor (sample) |

---

*This is a sample vault metadata document produced for academic coursework purposes. All card valuations, certificate numbers, and custodian details are illustrative only. This document does not constitute a financial prospectus or investment offer.*
