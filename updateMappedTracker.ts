import { RulesEngine, policyModifierGeneration, connectConfig } from '@fortefoundation/forte-rules-engine-sdk'
import * as fs from 'fs'
import {
  Address,
  createClient,
  createTestClient,
  getAddress,
  http,
  PrivateKeyAccount,
  publicActions,
  walletActions,
} from 'viem'
import { privateKeyToAccount } from 'viem/accounts'
import { Config, createConfig, mock, simulateContract } from '@wagmi/core'
import { foundry, sepolia, baseSepolia } from '@wagmi/core/chains'
import * as dotenv from 'dotenv'

dotenv.config()
// Hardcoded address of the diamond in diamondDeployedAnvilState.json
const RULES_ENGINE_ADDRESS: Address = getAddress(process.env.RULES_ENGINE_ADDRESS as string)
var config: Config
var RULES_ENGINE: RulesEngine

/**
 * The following address and private key are defaults from anvil and are only meant to be used in a test environment.
 */
//-------------------------------------------------------------------------------------------------------------
const foundryPrivateKey: `0x${string}` = process.env.PRIV_KEY as `0x${string}`
export const account: PrivateKeyAccount = privateKeyToAccount(foundryPrivateKey)
const foundryAccountAddress: `0x${string}` = process.env.USER_ADDRESS as `0x${string}`
//-------------------------------------------------------------------------------------------------------------

/**
 * Gets the chain configuration based on the NETWORK environment variable
 */
const getChainConfig = () => {
  const network = process.env.NETWORK?.toLowerCase()

  switch (network) {
    case 'sepolia':
      return sepolia
    case 'base-sepolia':
      return baseSepolia
    case 'local':
    case 'anvil':
    case 'foundry':
      return foundry
    default:
      return sepolia
  }
}

/**
 * Creates a connection to the specified network.
 * Supports: local/anvil, bsc, sepolia, basesepolia
 */
const createTestConfig = async () => {
  const selectedChain = getChainConfig()

  config = createConfig({
    chains: [selectedChain],
    client({ chain }) {
      return createClient({
        chain,
        transport: http(process.env.RPC_URL),
        account,
      })
        .extend(walletActions)
        .extend(publicActions)
    },
    connectors: [
      mock({
        accounts: [foundryAccountAddress],
      }),
    ],
  })
}

async function setupPolicy(policyData: string): Promise<number> {
  // Create a new policy
  try {
    const result = await RULES_ENGINE.createPolicy(policyData)
    console.log(`Policy \'${result.policyId}\' created successfully.`)
    return result.policyId
  } catch (error) {
    console.error(`Error creating policy: ${error}`)
    throw error
  }
}

async function injectModifiers(policyJSONFile: string, modifierFileName: string, sourceContractFile: string) {
  try {
    policyModifierGeneration(policyJSONFile, modifierFileName, [sourceContractFile])
  } catch (error) {
    console.error(`Error injecting modifiers: ${error}`)
    throw error
  }
}

async function applyPolicy(policyId: number, callingContractAddress: Address) {
  try {
    await validatePolicyId(policyId)

    // Apply the policy to the contract
    await RULES_ENGINE.appendPolicy(policyId, callingContractAddress)
    console.log('Policy applied!')
  } catch (error) {
    console.error(`Error applying policy: ${error}`)
    throw error
  }
}

async function updateMappedTracker(policyId: number, trackerId: number, trackerJson: string) {
  try {
    const result = await RULES_ENGINE.updateMappedTracker(policyId, trackerId, trackerJson)
    console.log(result)
    console.log('Mapped tracker updated!')
  } catch (error) {
    console.error(`Error updating mapped tracker: ${error}`)
    throw error
  }
}
async function getAllTrackers(policyId: number) {
  try {
    const trackers = await RULES_ENGINE.getAllTrackers(policyId)
    console.log(trackers)
  } catch (error) {
    console.error(`Error fetching tracker: ${error}`)
    throw error
  }
}

async function getTracker(policyId: number, trackerId: number) {
  try {
    const trackers = await RULES_ENGINE.getTracker(policyId, trackerId)
    console.log(trackers)
  } catch (error) {
    console.error(`Error fetching tracker: ${error}`)
    throw error
  }
}

async function getMappedTrackerValue(policyId: number, index: number, trackerKey: string) {
  try {
    const mappedTrackerValue = await RULES_ENGINE.getMappedTrackerValue(policyId, index, trackerKey)
    console.log(mappedTrackerValue)
  } catch (error) {
    console.error(`Error fetching tracker: ${error}`)
    throw error
  }
}

async function deletePolicy(policyId: number) {
  try {
    // Delete the policy!
    await RULES_ENGINE.deletePolicy(policyId)
    console.log('Policy deleted!')
  } catch (error) {
    console.error(`Error deleteing policy: ${error}`)
    throw error
  }
}

async function validatePolicyId(policyId: number): Promise<boolean> {
  // Check if the policy ID is a valid number
  if (isNaN(policyId) || policyId <= 0) {
    throw new Error(`Invalid policy ID: ${policyId}. The policy ID must be a number greater than 0.`)
  }
  // Check if the policy ID is valid
  const policy = await RULES_ENGINE.policyExists(policyId)
  if (!policy) {
    // TODO update this check
    throw new Error(`Policy ID ${policyId} does not exist.`)
  }
  return true
}

async function main() {
  await createTestConfig()
  var client = config.getClient({ chainId: config.chains[0].id })
  // Determine confirmation count based on network
  const network = process.env.NETWORK?.toLowerCase()
  const confirmationCount = network === 'base-sepolia' ? 2 : 1

  const rulesEngineResult = await RulesEngine.create(RULES_ENGINE_ADDRESS, config, client, confirmationCount)
  if (!rulesEngineResult) {
    throw new Error('Failed to create RulesEngine instance')
  }
  RULES_ENGINE = rulesEngineResult
  await connectConfig(config, 0)
  // Assuming a syntax of npx <run command> <args>
  if (process.argv[2] == 'setupPolicy') {
    // setupPolicy - npx setupPolicy <OPTIONAL: policyJSONFilePath>
    var policyJSONFile = process.argv[3]
    if (!policyJSONFile) {
      policyJSONFile = 'policy.json'
    }
    let policyData: string = fs.readFileSync(policyJSONFile, 'utf8')
    if (!policyData) {
      console.error(`Policy JSON file ${policyJSONFile} does not exist.`)
      return
    }
    await setupPolicy(policyData)
  } else if (process.argv[2] === 'deletePolicy') {
    const policyId = Number(process.argv[3])
    await validatePolicyId(policyId)
    await deletePolicy(policyId)
  } else if (process.argv[2] == 'injectModifiers') {
    // injectModifiers - npx injectModifiers <policyJSONFilePath> <newModifierFileName> <sourceContractFile>
    // npx tsx index.ts injectModifiers policy.json src/RulesEngineIntegration src/ExampleContract.sol
    const policyJSONFile = process.argv[3] || 'policy.json'
    const newModifierFileName = process.argv[4] || 'src/RulesEngineIntegration.sol'
    const sourceContractFile = process.argv[5] || 'src/ExampleContract.sol'
    await injectModifiers(policyJSONFile, newModifierFileName, sourceContractFile)
  } else if (process.argv[2] == 'applyPolicy') {
    // applyPolicy - npx applyPolicy <policyId> <address>
    const policyId = Number(process.argv[3])
    await validatePolicyId(policyId)
    const callingContractAddress = getAddress(process.argv[4])
    await applyPolicy(policyId, callingContractAddress)
  } else if (process.argv[2] == 'getAllTrackers') {
    const policyId = Number(process.argv[3])
    await getAllTrackers(policyId)
    // const callingContractAddress = getAddress(process.argv[4])
    // await applyPolicy(policyId, callingContractAddress)
  } else if (process.argv[2] == 'getTracker') {
    const policyId = Number(process.argv[3])
    const trackerId = Number(process.argv[4])
    await getTracker(policyId, trackerId)
    // const callingContractAddress = getAddress(process.argv[4])
    // await applyPolicy(policyId, callingContractAddress)
  } else if (process.argv[2] == 'getMappedTrackerValue') {
    const policyId = Number(process.argv[3])
    const index = Number(process.argv[4])
    const trackerKey = process.argv[5]
    await getMappedTrackerValue(policyId, index, trackerKey)
    // const callingContractAddress = getAddress(process.argv[4])
    // await applyPolicy(policyId, callingContractAddress)
  } else if (process.argv[2] == 'updateMappedTracker') {
    const policyId = Number(process.argv[3])
    const trackerId = Number(process.argv[4])
    const trackerJson = {
      Name: 'VestAmount',
      KeyType: 'address',
      ValueType: 'uint256',
      InitialKeys: ['0x1234567890123456789012345678901234567890'],
      InitialValues: ['1000000000000000000'],
    }
    console.log(JSON.stringify(trackerJson))
    await updateMappedTracker(policyId, trackerId, JSON.stringify(trackerJson))
    // const callingContractAddress = getAddress(process.argv[4])
    // await applyPolicy(policyId, callingContractAddress)
  } else {
    console.log('Invalid command. Please use one of the following commands:')
    console.log('     setupPolicy <OPTIONAL: policyJSONFilePath>')
    console.log('     injectModifiers <policyId> <sourceContractFile> <destinationModifierFile>')
    console.log('     applyPolicy <policyId> <address>')
  }
}

main()
