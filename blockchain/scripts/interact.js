// Script to interact with deployed PartTrace contract
const { ethers } = require("hardhat");

async function main() {
    // Contract address (update with deployed address)
    const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // Replace with actual address
    
    // Get contract instance
    const PartTrace = await ethers.getContractFactory("PartTrace");
    const partTrace = PartTrace.attach(contractAddress);
    
    console.log("Interacting with PartTrace contract at:", contractAddress);
    
    // Example 1: Register a new part
    console.log("\n1. Registering new part...");
    try {
        const tx1 = await partTrace.registerPart(
            "SL-2024-002",
            "Signal Light LED Assembly",
            "Metro Components Ltd",
            "Manufactured",
            "Production Line B"
        );
        await tx1.wait();
        console.log("✓ Part registered successfully");
    } catch (error) {
        console.log("Part may already exist:", error.message);
    }
    
    // Example 2: Update part status
    console.log("\n2. Updating part status...");
    const tx2 = await partTrace.updatePart(
        "SL-2024-002",
        "Quality Tested",
        "QC Department",
        "Passed all quality tests"
    );
    await tx2.wait();
    console.log("✓ Part status updated");
    
    // Example 3: Verify part details
    console.log("\n3. Verifying part details...");
    const partDetails = await partTrace.verifyPart("SL-2024-002");
    console.log("Part Details:", {
        name: partDetails[0],
        manufacturer: partDetails[1],
        currentStatus: partDetails[2],
        owner: partDetails[3],
        createdAt: new Date(partDetails[4] * 1000).toLocaleString(),
        updatedAt: new Date(partDetails[5] * 1000).toLocaleString()
    });
    
    // Example 4: Get part history
    console.log("\n4. Getting part history...");
    const history = await partTrace.getPartHistory("SL-2024-002");
    console.log("Part History:");
    for (let i = 0; i < history[0].length; i++) {
        console.log(`  ${i + 1}. Status: ${history[0][i]}`);
        console.log(`     Location: ${history[1][i]}`);
        console.log(`     Updated by: ${history[2][i]}`);
        console.log(`     Timestamp: ${new Date(history[3][i] * 1000).toLocaleString()}`);
        console.log(`     Remarks: ${history[4][i]}`);
        console.log("");
    }
    
    // Example 5: Transfer ownership
    console.log("\n5. Transferring ownership...");
    const [owner, addr1] = await ethers.getSigners();
    const tx3 = await partTrace.transferOwnership("SL-2024-002", addr1.address);
    await tx3.wait();
    console.log("✓ Ownership transferred to:", addr1.address);
    
    // Example 6: Check current owner
    const currentOwner = await partTrace.getPartOwner("SL-2024-002");
    console.log("Current owner:", currentOwner);
    
    // Example 7: Authorize new user
    console.log("\n6. Authorizing new user...");
    const tx4 = await partTrace.setAuthorization(addr1.address, true);
    await tx4.wait();
    console.log("✓ User authorized:", addr1.address);
    
    console.log("\n✓ All interactions completed successfully!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });