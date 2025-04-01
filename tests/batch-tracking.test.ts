import { describe, it, expect, beforeEach } from "vitest"
import { initSimnet, getAccounts, callPublicFn } from "./test-utils"

describe("Batch Tracking Contract", () => {
  let simnet: any
  let accounts: any
  let admin: string
  let manufacturer: string
  let distributor: string
  let retailer: string
  
  beforeEach(async () => {
    simnet = await initSimnet()
    accounts = getAccounts(simnet)
    admin = accounts.deployer.address
    manufacturer = accounts.wallet_1.address
    distributor = accounts.wallet_2.address
    retailer = accounts.wallet_3.address
  })
  
  it("should allow manufacturer to register a batch", async () => {
    const result = await callPublicFn({
      simnet,
      contract: "batch-tracking",
      method: "register-batch",
      args: ['"BATCH001"', '"PROD001"', "u1000"],
      sender: manufacturer,
    })
    
    expect(result.success).toBe(true)
  })
  
  it("should allow batch transfer to another entity", async () => {
    // First register a batch
    await callPublicFn({
      simnet,
      contract: "batch-tracking",
      method: "register-batch",
      args: ['"BATCH001"', '"PROD001"', "u1000"],
      sender: manufacturer,
    })
    
    // Then transfer the batch
    const result = await callPublicFn({
      simnet,
      contract: "batch-tracking",
      method: "transfer-batch",
      args: ['"BATCH001"', `'${distributor}`, '"Warehouse A"', '"Regular shipment"'],
      sender: manufacturer,
    })
    
    expect(result.success).toBe(true)
  })
  
  it("should allow multiple transfers along the supply chain", async () => {
    // Register and initial transfer
    await callPublicFn({
      simnet,
      contract: "batch-tracking",
      method: "register-batch",
      args: ['"BATCH001"', '"PROD001"', "u1000"],
      sender: manufacturer,
    })
    
    await callPublicFn({
      simnet,
      contract: "batch-tracking",
      method: "transfer-batch",
      args: ['"BATCH001"', `'${distributor}`, '"Warehouse A"', '"Regular shipment"'],
      sender: manufacturer,
    })
    
    // Second transfer
    const result = await callPublicFn({
      simnet,
      contract: "batch-tracking",
      method: "transfer-batch",
      args: ['"BATCH001"', `'${retailer}`, '"Pharmacy Store"', '"Final delivery"'],
      sender: distributor,
    })
    
    expect(result.success).toBe(true)
  })
  
  it("should allow admin to mark a batch as expired", async () => {
    // Register a batch
    await callPublicFn({
      simnet,
      contract: "batch-tracking",
      method: "register-batch",
      args: ['"BATCH001"', '"PROD001"', "u1000"],
      sender: manufacturer,
    })
    
    // Mark as expired
    const result = await callPublicFn({
      simnet,
      contract: "batch-tracking",
      method: "mark-batch-expired",
      args: ['"BATCH001"'],
      sender: admin,
    })
    
    expect(result.success).toBe(true)
  })
})

