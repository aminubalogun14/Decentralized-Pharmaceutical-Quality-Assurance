import { describe, it, expect, beforeEach } from "vitest"
import { initSimnet, getAccounts, callReadOnlyFn, callPublicFn } from "./test-utils"

describe("Manufacturer Verification Contract", () => {
  let simnet: any
  let accounts: any
  let admin: string
  let manufacturer1: string
  let manufacturer2: string
  
  beforeEach(async () => {
    simnet = await initSimnet()
    accounts = getAccounts(simnet)
    admin = accounts.deployer.address
    manufacturer1 = accounts.wallet_1.address
    manufacturer2 = accounts.wallet_2.address
  })
  
  it("should allow admin to register a manufacturer", async () => {
    const result = await callPublicFn({
      simnet,
      contract: "manufacturer-verification",
      method: "register-manufacturer",
      args: ['"Pharma Inc."', '"LICENSE123"'],
      sender: admin,
    })
    
    expect(result.success).toBe(true)
  })
  
  it("should allow admin to verify a manufacturer", async () => {
    // First register the manufacturer
    await callPublicFn({
      simnet,
      contract: "manufacturer-verification",
      method: "register-manufacturer",
      args: ['"Pharma Inc."', '"LICENSE123"'],
      sender: admin,
    })
    
    // Then verify the manufacturer
    const result = await callPublicFn({
      simnet,
      contract: "manufacturer-verification",
      method: "verify-manufacturer",
      args: [`'${admin}`],
      sender: admin,
    })
    
    expect(result.success).toBe(true)
    
    // Check if manufacturer is verified
    const isVerified = await callReadOnlyFn({
      simnet,
      contract: "manufacturer-verification",
      method: "is-verified",
      args: [`'${admin}`],
      sender: admin,
    })
    
    expect(isVerified.result).toBe("true")
  })
  
  it("should allow admin to transfer admin rights", async () => {
    const result = await callPublicFn({
      simnet,
      contract: "manufacturer-verification",
      method: "transfer-admin",
      args: [`'${manufacturer1}`],
      sender: admin,
    })
    
    expect(result.success).toBe(true)
    
    // New admin should be able to register a manufacturer
    const registerResult = await callPublicFn({
      simnet,
      contract: "manufacturer-verification",
      method: "register-manufacturer",
      args: ['"New Pharma"', '"NEW789"'],
      sender: manufacturer1,
    })
    
    expect(registerResult.success).toBe(true)
  })
})

