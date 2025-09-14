// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title PartTrace
 * @dev Smart contract for railway parts traceability and supply chain tracking
 * @author Railway Parts Management System
 */
contract PartTrace {
    
    // Part structure to store complete part information
    struct Part {
        string partId;           // Unique part identifier
        string name;             // Part name/description
        string manufacturer;     // Manufacturer name
        string currentStatus;    // Current status (manufactured, shipped, installed, etc.)
        address owner;           // Current owner address
        uint256 createdAt;       // Creation timestamp
        uint256 updatedAt;       // Last update timestamp
        bool exists;             // Flag to check if part exists
    }
    
    // Status update history entry
    struct StatusUpdate {
        string status;           // Status description
        string location;         // Location of update
        address updatedBy;       // Address that made the update
        uint256 timestamp;       // Update timestamp
        string remarks;          // Additional remarks
    }
    
    // Mappings for data storage
    mapping(string => Part) private parts;                              // partId => Part
    mapping(string => StatusUpdate[]) private partHistory;              // partId => StatusUpdate[]
    mapping(address => bool) public authorizedUsers;                    // Authorized addresses
    
    // Contract owner
    address public owner;
    
    // Events for traceability and logging
    event PartRegistered(
        string indexed partId,
        string name,
        string manufacturer,
        address indexed registeredBy,
        uint256 timestamp
    );
    
    event PartUpdated(
        string indexed partId,
        string newStatus,
        string location,
        address indexed updatedBy,
        uint256 timestamp
    );
    
    event OwnershipTransferred(
        string indexed partId,
        address indexed previousOwner,
        address indexed newOwner,
        uint256 timestamp
    );
    
    event UserAuthorized(address indexed user, bool authorized);
    
    // Modifiers for access control
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }
    
    modifier onlyAuthorized() {
        require(authorizedUsers[msg.sender] || msg.sender == owner, "Not authorized to perform this action");
        _;
    }
    
    modifier partExists(string memory partId) {
        require(parts[partId].exists, "Part does not exist");
        _;
    }
    
    modifier partNotExists(string memory partId) {
        require(!parts[partId].exists, "Part already exists");
        _;
    }
    
    /**
     * @dev Constructor - sets contract deployer as owner and authorizes them
     */
    constructor() {
        owner = msg.sender;
        authorizedUsers[msg.sender] = true;
    }
    
    /**
     * @dev Register a new part in the supply chain
     * @param partId Unique identifier for the part
     * @param name Part name/description
     * @param manufacturer Manufacturer name
     * @param initialStatus Initial status of the part
     * @param location Initial location
     */
    function registerPart(
        string memory partId,
        string memory name,
        string memory manufacturer,
        string memory initialStatus,
        string memory location
    ) external onlyAuthorized partNotExists(partId) {
        
        // Create new part
        parts[partId] = Part({
            partId: partId,
            name: name,
            manufacturer: manufacturer,
            currentStatus: initialStatus,
            owner: msg.sender,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            exists: true
        });
        
        // Add initial status to history
        partHistory[partId].push(StatusUpdate({
            status: initialStatus,
            location: location,
            updatedBy: msg.sender,
            timestamp: block.timestamp,
            remarks: "Part registered"
        }));
        
        // Emit registration event
        emit PartRegistered(partId, name, manufacturer, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Update part status and add to history
     * @param partId Part identifier
     * @param newStatus New status description
     * @param location Current location
     * @param remarks Additional remarks
     */
    function updatePart(
        string memory partId,
        string memory newStatus,
        string memory location,
        string memory remarks
    ) external onlyAuthorized partExists(partId) {
        
        // Update part status and timestamp
        parts[partId].currentStatus = newStatus;
        parts[partId].updatedAt = block.timestamp;
        
        // Add status update to history
        partHistory[partId].push(StatusUpdate({
            status: newStatus,
            location: location,
            updatedBy: msg.sender,
            timestamp: block.timestamp,
            remarks: remarks
        }));
        
        // Emit update event
        emit PartUpdated(partId, newStatus, location, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Transfer ownership of a part
     * @param partId Part identifier
     * @param newOwner New owner address
     */
    function transferOwnership(
        string memory partId,
        address newOwner
    ) external onlyAuthorized partExists(partId) {
        require(newOwner != address(0), "Invalid new owner address");
        
        address previousOwner = parts[partId].owner;
        parts[partId].owner = newOwner;
        parts[partId].updatedAt = block.timestamp;
        
        // Add ownership transfer to history
        partHistory[partId].push(StatusUpdate({
            status: "Ownership Transferred",
            location: "",
            updatedBy: msg.sender,
            timestamp: block.timestamp,
            remarks: string(abi.encodePacked("Transferred to: ", toAsciiString(newOwner)))
        }));
        
        emit OwnershipTransferred(partId, previousOwner, newOwner, block.timestamp);
    }
    
    /**
     * @dev Verify and get part details
     * @param partId Part identifier
     * @return name Part name
     * @return manufacturer Part manufacturer
     * @return currentStatus Current status
     * @return currentOwner Current owner address
     * @return createdAt Creation timestamp
     * @return updatedAt Last update timestamp
     */
    function verifyPart(string memory partId) external view partExists(partId) returns (
        string memory name,
        string memory manufacturer,
        string memory currentStatus,
        address currentOwner,
        uint256 createdAt,
        uint256 updatedAt
    ) {
        Part memory part = parts[partId];
        return (
            part.name,
            part.manufacturer,
            part.currentStatus,
            part.owner,
            part.createdAt,
            part.updatedAt
        );
    }
    
    /**
     * @dev Get complete history of a part
     * @param partId Part identifier
     * @return statuses Array of status strings
     * @return locations Array of location strings
     * @return updatedBy Array of updater addresses
     * @return timestamps Array of timestamps
     * @return remarks Array of remarks
     */
    function getPartHistory(string memory partId) external view partExists(partId) returns (
        string[] memory statuses,
        string[] memory locations,
        address[] memory updatedBy,
        uint256[] memory timestamps,
        string[] memory remarks
    ) {
        StatusUpdate[] memory history = partHistory[partId];
        uint256 length = history.length;
        
        statuses = new string[](length);
        locations = new string[](length);
        updatedBy = new address[](length);
        timestamps = new uint256[](length);
        remarks = new string[](length);
        
        for (uint256 i = 0; i < length; i++) {
            statuses[i] = history[i].status;
            locations[i] = history[i].location;
            updatedBy[i] = history[i].updatedBy;
            timestamps[i] = history[i].timestamp;
            remarks[i] = history[i].remarks;
        }
        
        return (statuses, locations, updatedBy, timestamps, remarks);
    }
    
    /**
     * @dev Check if a part exists
     * @param partId Part identifier
     * @return Boolean indicating existence
     */
    function checkPartExists(string memory partId) external view returns (bool) {
        return parts[partId].exists;
    }
    
    /**
     * @dev Get current part status
     * @param partId Part identifier
     * @return Current status string
     */
    function getCurrentStatus(string memory partId) external view partExists(partId) returns (string memory) {
        return parts[partId].currentStatus;
    }
    
    /**
     * @dev Get part owner
     * @param partId Part identifier
     * @return Owner address
     */
    function getPartOwner(string memory partId) external view partExists(partId) returns (address) {
        return parts[partId].owner;
    }
    
    /**
     * @dev Authorize or deauthorize a user
     * @param user User address
     * @param authorized Authorization status
     */
    function setAuthorization(address user, bool authorized) external onlyOwner {
        authorizedUsers[user] = authorized;
        emit UserAuthorized(user, authorized);
    }
    
    /**
     * @dev Transfer contract ownership
     * @param newOwner New contract owner
     */
    function transferContractOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        owner = newOwner;
        authorizedUsers[newOwner] = true;
    }
    
    /**
     * @dev Convert address to string (helper function)
     * @param addr Address to convert
     * @return String representation
     */
    function toAsciiString(address addr) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(addr)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }
    
    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}