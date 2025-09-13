# Railway Parts Blockchain Traceability

## Overview
Ethereum smart contract system for immutable railway parts traceability and supply chain management using blockchain technology.

## Smart Contract Features

### PartTrace Contract
- **Part Registration**: Register new parts with complete metadata
- **Status Updates**: Track part status throughout supply chain
- **Ownership Transfer**: Transfer part ownership between entities
- **History Tracking**: Immutable history of all part updates
- **Access Control**: Role-based permissions for authorized users
- **Event Logging**: Comprehensive event emission for traceability

## Contract Functions

### Core Functions

**registerPart()**
```solidity
function registerPart(
    string memory partId,
    string memory name,
    string memory manufacturer,
    string memory initialStatus,
    string memory location
) external onlyAuthorized
```
- Registers new part in blockchain
- Emits `PartRegistered` event
- Creates initial history entry

**updatePart()**
```solidity
function updatePart(
    string memory partId,
    string memory newStatus,
    string memory location,
    string memory remarks
) external onlyAuthorized
```
- Updates part status and location
- Adds entry to part history
- Emits `PartUpdated` event

**verifyPart()**
```solidity
function verifyPart(string memory partId) external view returns (
    string memory name,
    string memory manufacturer,
    string memory currentStatus,
    address currentOwner,
    uint256 createdAt,
    uint256 updatedAt
)
```
- Returns complete part information
- Read-only function for verification

### Additional Functions
- `transferOwnership()` - Transfer part ownership
- `getPartHistory()` - Get complete part history
- `setAuthorization()` - Manage user permissions
- `partExists()` - Check if part exists

## Data Structures

### Part Struct
```solidity
struct Part {
    string partId;
    string name;
    string manufacturer;
    string currentStatus;
    address owner;
    uint256 createdAt;
    uint256 updatedAt;
    bool exists;
}
```

### StatusUpdate Struct
```solidity
struct StatusUpdate {
    string status;
    string location;
    address updatedBy;
    uint256 timestamp;
    string remarks;
}
```

## Events

```solidity
event PartRegistered(string indexed partId, string name, string manufacturer, address indexed registeredBy, uint256 timestamp);
event PartUpdated(string indexed partId, string newStatus, string location, address indexed updatedBy, uint256 timestamp);
event OwnershipTransferred(string indexed partId, address indexed previousOwner, address indexed newOwner, uint256 timestamp);
```

## Installation & Setup

### Prerequisites
```bash
npm install -g hardhat
```

### Install Dependencies
```bash
npm install
```

### Environment Setup
```bash
cp .env.example .env
# Edit .env with your configuration
```

## Usage

### Compile Contract
```bash
npm run compile
```

### Run Tests
```bash
npm run test
```

### Deploy to Local Network
```bash
# Start local blockchain
npm run node

# Deploy contract (in another terminal)
npm run deploy:localhost
```

### Deploy to Testnet
```bash
# Sepolia testnet
npm run deploy:sepolia

# Mumbai testnet
npm run deploy:mumbai
```

### Interact with Contract
```bash
node scripts/interact.js
```

## Example Usage

### Register a Part
```javascript
await partTrace.registerPart(
    "BP-2024-001",
    "Brake Pad Assembly",
    "Railway Parts Ltd",
    "Manufactured",
    "Factory Floor A"
);
```

### Update Part Status
```javascript
await partTrace.updatePart(
    "BP-2024-001",
    "Shipped",
    "Warehouse B",
    "Shipped to customer site"
);
```

### Verify Part
```javascript
const partDetails = await partTrace.verifyPart("BP-2024-001");
console.log("Part:", partDetails);
```

### Get Part History
```javascript
const history = await partTrace.getPartHistory("BP-2024-001");
// Returns arrays of statuses, locations, updaters, timestamps, remarks
```

## Security Features

### Access Control
- **Owner**: Contract deployer with full permissions
- **Authorized Users**: Addresses authorized by owner
- **Modifiers**: `onlyOwner`, `onlyAuthorized`, `partExists`

### Data Integrity
- **Immutable History**: All updates permanently recorded
- **Event Logging**: Complete audit trail via events
- **Input Validation**: Comprehensive parameter checking

## Gas Optimization
- Efficient data structures
- Optimized loops and operations
- Compiler optimization enabled

## Testing
Comprehensive test suite covering:
- Contract deployment
- Part registration and updates
- Access control mechanisms
- Event emission verification
- Error handling scenarios

## Network Support
- **Local Development**: Hardhat network
- **Testnets**: Sepolia, Mumbai
- **Mainnet**: Ethereum, Polygon

## Integration
The smart contract can be integrated with:
- Web3 applications
- Backend APIs
- Mobile applications
- IoT devices for automatic updates

## File Structure
```
blockchain/
├── contracts/
│   └── PartTrace.sol          # Main smart contract
├── scripts/
│   ├── deploy.js              # Deployment script
│   └── interact.js            # Interaction examples
├── test/
│   └── PartTrace.test.js      # Test suite
├── hardhat.config.js          # Hardhat configuration
├── package.json               # Dependencies
└── README.md                  # This file
```