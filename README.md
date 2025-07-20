# CrowdfundingCampaign Platform

A decentralized project funding system built on Stacks blockchain, enabling creators to launch campaigns, backers to contribute, and moderators to verify projects.

## Features

- **Campaign Launch**: Creators can launch funding campaigns with minimum pledge amounts
- **Backer Support**: Community members can back projects with financial contributions
- **Moderator Verification**: Head moderator validates and verifies campaign legitimacy
- **Funding Tracking**: Complete backing and verification history on-chain

## Smart Contract Functions

### Public Functions
- `launch-campaign`: Launch new crowdfunding campaign
- `back-campaign`: Back existing campaign with pledge
- `verify-campaign`: Verify campaign legitimacy (moderator only)

### Read-Only Functions
- `get-campaign`: Retrieve campaign details
- `get-backing-history`: Get specific backing record
- `get-backer-count`: Get total backers for campaign

## Getting Started

1. Deploy the contract to Stacks blockchain
2. Set head moderator address
3. Creators can launch funding campaigns
4. Backers can support and moderators can verify

## License

MIT License
```

**PR Title**: feat: implement crowdfunding campaign platform with moderator verification

**PR Description**: 
Introduces a decentralized crowdfunding platform enabling creators to launch campaigns, backers to contribute funds, and moderators to verify project legitimacy with transparent funding tracking.

**Commit Messages**:
- README: `docs: add documentation for crowdfunding campaign platform`
- Code: `feat: implement crowdfunding with backing and verification system`

**Branch Name**: `feature/crowdfunding-platform`

---

