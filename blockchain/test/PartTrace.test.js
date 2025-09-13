// Test suite for PartTrace smart contract
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PartTrace", function () {
    let PartTrace;
    let partTrace;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        // Get signers
        [owner, addr1, addr2] = await ethers.getSigners();
        
        // Deploy contract
        PartTrace = await ethers.getContractFactory("PartTrace");
        partTrace = await PartTrace.deploy();
        await partTrace.deployed();
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await partTrace.owner()).to.equal(owner.address);
        });

        it("Should authorize the owner", async function () {
            expect(await partTrace.authorizedUsers(owner.address)).to.equal(true);
        });
    });

    describe("Part Registration", function () {
        it("Should register a new part", async function () {
            await partTrace.registerPart(
                "BP-2024-001",
                "Brake Pad Assembly",
                "Railway Parts Ltd",
                "Manufactured",
                "Factory A"
            );

            const partDetails = await partTrace.verifyPart("BP-2024-001");
            expect(partDetails[0]).to.equal("Brake Pad Assembly");
            expect(partDetails[1]).to.equal("Railway Parts Ltd");
            expect(partDetails[2]).to.equal("Manufactured");
        });

        it("Should emit PartRegistered event", async function () {
            await expect(partTrace.registerPart(
                "BP-2024-001",
                "Brake Pad Assembly",
                "Railway Parts Ltd",
                "Manufactured",
                "Factory A"
            )).to.emit(partTrace, "PartRegistered")
              .withArgs("BP-2024-001", "Brake Pad Assembly", "Railway Parts Ltd", owner.address);
        });

        it("Should not allow duplicate part registration", async function () {
            await partTrace.registerPart(
                "BP-2024-001",
                "Brake Pad Assembly",
                "Railway Parts Ltd",
                "Manufactured",
                "Factory A"
            );

            await expect(partTrace.registerPart(
                "BP-2024-001",
                "Duplicate Part",
                "Another Manufacturer",
                "Manufactured",
                "Factory B"
            )).to.be.revertedWith("Part already exists");
        });
    });

    describe("Part Updates", function () {
        beforeEach(async function () {
            await partTrace.registerPart(
                "BP-2024-001",
                "Brake Pad Assembly",
                "Railway Parts Ltd",
                "Manufactured",
                "Factory A"
            );
        });

        it("Should update part status", async function () {
            await partTrace.updatePart(
                "BP-2024-001",
                "Shipped",
                "Warehouse B",
                "Shipped to customer"
            );

            const status = await partTrace.getCurrentStatus("BP-2024-001");
            expect(status).to.equal("Shipped");
        });

        it("Should emit PartUpdated event", async function () {
            await expect(partTrace.updatePart(
                "BP-2024-001",
                "Shipped",
                "Warehouse B",
                "Shipped to customer"
            )).to.emit(partTrace, "PartUpdated")
              .withArgs("BP-2024-001", "Shipped", "Warehouse B", owner.address);
        });

        it("Should maintain part history", async function () {
            await partTrace.updatePart("BP-2024-001", "Shipped", "Warehouse B", "Shipped");
            await partTrace.updatePart("BP-2024-001", "Delivered", "Customer Site", "Delivered");

            const history = await partTrace.getPartHistory("BP-2024-001");
            expect(history[0].length).to.equal(3); // Initial + 2 updates
            expect(history[0][1]).to.equal("Shipped");
            expect(history[0][2]).to.equal("Delivered");
        });
    });

    describe("Authorization", function () {
        it("Should allow owner to authorize users", async function () {
            await partTrace.setAuthorization(addr1.address, true);
            expect(await partTrace.authorizedUsers(addr1.address)).to.equal(true);
        });

        it("Should not allow unauthorized users to register parts", async function () {
            await expect(partTrace.connect(addr1).registerPart(
                "BP-2024-001",
                "Brake Pad Assembly",
                "Railway Parts Ltd",
                "Manufactured",
                "Factory A"
            )).to.be.revertedWith("Not authorized to perform this action");
        });

        it("Should allow authorized users to register parts", async function () {
            await partTrace.setAuthorization(addr1.address, true);
            
            await partTrace.connect(addr1).registerPart(
                "BP-2024-001",
                "Brake Pad Assembly",
                "Railway Parts Ltd",
                "Manufactured",
                "Factory A"
            );

            const exists = await partTrace.partExists("BP-2024-001");
            expect(exists).to.equal(true);
        });
    });

    describe("Ownership Transfer", function () {
        beforeEach(async function () {
            await partTrace.registerPart(
                "BP-2024-001",
                "Brake Pad Assembly",
                "Railway Parts Ltd",
                "Manufactured",
                "Factory A"
            );
        });

        it("Should transfer part ownership", async function () {
            await partTrace.transferOwnership("BP-2024-001", addr1.address);
            
            const newOwner = await partTrace.getPartOwner("BP-2024-001");
            expect(newOwner).to.equal(addr1.address);
        });

        it("Should emit OwnershipTransferred event", async function () {
            await expect(partTrace.transferOwnership("BP-2024-001", addr1.address))
                .to.emit(partTrace, "OwnershipTransferred")
                .withArgs("BP-2024-001", owner.address, addr1.address);
        });
    });

    describe("Part Verification", function () {
        it("Should return false for non-existent parts", async function () {
            const exists = await partTrace.partExists("NON-EXISTENT");
            expect(exists).to.equal(false);
        });

        it("Should revert when verifying non-existent parts", async function () {
            await expect(partTrace.verifyPart("NON-EXISTENT"))
                .to.be.revertedWith("Part does not exist");
        });
    });
});