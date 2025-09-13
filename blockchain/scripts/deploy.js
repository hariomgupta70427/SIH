// Deployment script for PartTrace smart contract
const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying PartTrace contract...");
    
    // Get the contract factory
    const PartTrace = await ethers.getContractFactory("PartTrace");
    
    // Deploy the contract
    const partTrace = await PartTrace.deploy();
    
    // Wait for deployment to complete
    await partTrace.deployed();
    
    console.log("PartTrace deployed to:", partTrace.address);
    console.log("Contract owner:", await partTrace.owner());
    
    // Verify deployment by checking contract code
    const code = await ethers.provider.getCode(partTrace.address);
    if (code === "0x") {
        console.error("Contract deployment failed - no code at address");
    } else {
        console.log("Contract successfully deployed with code");
    }
    
    // Example: Register a sample part
    console.log("\nRegistering sample part...");
    const tx = await partTrace.registerPart(
        "BP-2024-001",
        "Brake Pad Assembly",
        "Railway Parts Ltd",
        "Manufactured",
        "Factory Floor A"
    );
    
    await tx.wait();
    console.log("Sample part registered successfully");
    
    // Verify the part
    const partDetails = await partTrace.verifyPart("BP-2024-001");
    console.log("Part verification:", {
        name: partDetails[0],
        manufacturer: partDetails[1],
        status: partDetails[2],
        owner: partDetails[3]
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });