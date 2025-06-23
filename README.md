# Forte Rules Engine Quickstart (UNDER DEVELOPMENT)

This repository will guide you through using the Forte Rules Engine in a local [anvil](https://book.getfoundry.sh/anvil/) devlopment environement utilizing the [Forte Rules Engine SDK](https://github.com/thrackle-io/forte-rules-engine-sdk). This guide will go over:

1. Environment prerequisites
2. Building
3. Starting a local Anvil instance
4. Configuring your environment
5. Creating a sample policy in the Rules Engine
6. Configuring and Deploying the ExampleContract
7. Setting the Rules Engine Address in the ExampleContract
8. Set your address as the Calling Contract Admin
9. Applying the policy to the sample contract and verifying functionality

> **_NOTE:_** This guide was developed in a MacOS environment, some modification may be necessary to suit a Linux/Windows environment.

## 1. Environment dependencies

This guide assumes the following tools are installed and configured correctly. Please see each tool's installation instructions for more details:

- [Git](https://git-scm.com/)
- [NodeJS](https://nodejs.org/) - v20.x.x
- [Foundry](https://book.getfoundry.sh/getting-started/installation) - v1.0.0-stable

## 2. Building

Create a copy of our template repository in your own github account by navigating here: https://github.com/thrackle-io/fre-quickstart and clicking the "Use this template" button on GitHub.

![Screenshot showing how to copy repo as a template](https://mintlify.s3.us-west-1.amazonaws.com/thrackle/images/use-template-gh.jpg)

Next, clone the freshly created repository to your local machine:

```bash
git clone https://github.com/<YOUR_GITHUB_USERNAME>/fre-quickstart
```

> **_NOTE:_** If you named the repository something different than `fre-quickstart`, use that name in the clone command instead.

Navigate to the repository in your local shell. To build the repository, run the following commands:

```shell
npm install
forge install
```

## 3. Starting a local Anvil chain

An Anvil [dumpState](https://book.getfoundry.sh/reference/anvil/) file is provided with a pre-deployed Rules Engine instance. Start the local Anvil instance in a terminal window with the following command:

```bash
anvil --load-state anvilState.json
```

`Listening on 127.0.0.1:8545` should be the last thing displayed if the state file was successfuly loaded. Leave this Anvil instance running in this terminal for the rest of the quickstart. It may be restarted at any time but restarting will lose any on-chain progress you've made during the quickstart.

## 4. Configure your local environment

The .env.local environment file contains the following configurations:

- **RPC_URL** - The RPC endpoint to utilize when interacting with an EVM chain. This is defaulted to a local anvil RPC that is enabled when starting anvil. This can be updated to point to any testnet/mainnet RPC if desired. See [anvil](https://book.getfoundry.sh/anvil/) for more details.

```yaml+
# local anvil RPC, change this if you're deploying to a network
RPC_URL=http://127.0.0.1:8545
```

- **PRIV_KEY** - The private key for the account that will be performing the actions outlined in this guide. This is defaulted to a widely known default Anvil account for the purposes of this guide. It is recommended that this be updated prior to deploying to any testnet or mainnet.

```yaml+
# local anvil account private key, change to your deployer wallet key when using a live network
PRIV_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

- **RULES_ENGINE_ADDRESS** - The address of the deployed Rules Engine instance on the target RPC's chain. This is defaulted to the address where the Rules Engine was deployed in the anvilState.json file. For additional chain locations, please see the Forte Rules Engine docs for additional deployment locations.

```yaml+

# address of the rules engine within the anvil state file
RULES_ENGINE_ADDRESS=0x0165878A594ca255338adfa4d48449f69242Eb8F
```

Once you are satisfied with the above configurations open a new terminal window (separate from the running anvil instance) and ensure the variables are exported in your local shell with the following command:

```bash
cp .env.sample .env
source .env
```

> **_WARNING:_** The SDK utilizes the Rules Engine address and private key values from the environment file. This requires that you name your file `.env`, which enables the SDK to access the values.

### 5. Create the sample policy in the Rules Engine

To use the Rules engine, we must first create a policy. A default policy has been created within the [policy.json](./policy.json) that is tailored to work with the [ExampleContract](./src/ExampleContract.sol). To create this policy in the Rules Engine, run the following command:

```bash
npx tsx index.ts setupPolicy policy.json
```

Note the returned Policy Id, for this example the Policy Id should be 1, and create a local environment variable to store this Id for uses in subsequent commands:

```bash
export POLICY_ID=1
```

### 6. Configure and Deploy the ExampleContract

The [ExampleContract](./src/ExampleContract.sol) is a blank contract that conforms to a standard ERC20 interface transfer() function. The file does not store any data. The integration of the Rules Engine occurs by adding a modifier. This modifier may be generated by passing the policy information, destination modifier filename, and the example contract to the SDK. The SDK will process the policy, generate modifiers within the specified modifier file for each function within the Policy, and inject these newly generated modifiers within the supplied contract. This has been scripted in the index.ts with the following command:

```bash
npx tsx index.ts injectModifiers policy.json src/RulesEngineIntegration.sol src/ExampleContract.sol
```

After running this command, it will inject the beforeXXX() modifier within the function specified within the policy.json file. Verify the contract compiles and deploy the contract with the following commands:

```bash
forge script script/ExampleContract.s.sol --ffi --broadcast -vvv --non-interactive --rpc-url $RPC_URL --private-key $PRIV_KEY
```

Note the contract address, and export the address in your local terminal for subsequent testing.

```yaml
export CONTRACT_ADDRESS=<0xYourContractAddress>
```

### 7. Set Rules Engine Address in the ExampleContract

The ExampleContract extends the [RulesEngineClient](https://github.com/thrackle-io/forte-rules-engine/blob/main/src/client/RulesEngineClient.sol) to encapsulate storing the Rules Engine address and checks. It is recommended that all calling contracts extend this contract. This ensures calling contracts will only invoke the Rules Engine checks if the Rules Engine Address is specified. Set the Rules Engine Address in the ExampleContract via the following command:

```bash
cast send $CONTRACT_ADDRESS "setRulesEngineAddress(address)" $RULES_ENGINE_ADDRESS --rpc-url $RPC_URL --private-key $PRIV_KEY
```

To verify the address was set correct, the following commmand should return the same Rules Engine Address:

```bash
cast call $CONTRACT_ADDRESS "rulesEngineAddress()(address)" --rpc-url $RPC_URL
```

### 8. Set your address as the Calling Contract Admin

The ExampleContract extends the [RulesEngineClient](https://github.com/thrackle-io/forte-rules-engine/blob/main/src/client/RulesEngineClient.sol) to allow the ExampleContract to set the Calling Contract Admin. The Rules Engine requires this initial Admin designation to come directly from the Calling Contract. This ensures a malicious person cannot front-run setting the Calling Contract Admin. The setCallingContractAdmin() function MUST BE OVERRIDED WITH APPROPRIATE PERMISSION GATING in place for production instances. In this quickstart, we'll skip adding permission to this funciton since this is not a production environment. Set the Calling Contract Admin to the User Address with the following commands:

Verify it's not already set (should return 'false'):

```bash
cast call $RULES_ENGINE_ADDRESS "isCallingContractAdmin(address, address)(bool)" $CONTRACT_ADDRESS $USER_ADDRESS  --rpc-url $RPC_URL
```

Set the Calling Contract Admin:

```bash
cast send $CONTRACT_ADDRESS "setCallingContractAdmin(address)" $USER_ADDRESS --rpc-url $RPC_URL --private-key $PRIV_KEY
```

Verify the admin is now set (should return 'true'):

```bash
cast call $RULES_ENGINE_ADDRESS "isCallingContractAdmin(address, address)(bool)" $CONTRACT_ADDRESS $USER_ADDRESS  --rpc-url $RPC_URL
```

### 9. Apply the Policy and Test

```bash
npx tsx index.ts applyPolicy $POLICY_ID $CONTRACT_ADDRESS
```

### Test Success Condition

```bash
cast send $CONTRACT_ADDRESS "transfer(address,uint256)" 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 10001 --rpc-url $RPC_URL --private-key $PRIV_KEY
```

You should receive a successful transaction!

### Test Failure Condition

```bash
cast send $CONTRACT_ADDRESS "transfer(address,uint256)" 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 9999 --rpc-url $RPC_URL --private-key $PRIV_KEY
```

You should receive a revert with the text "Transfer Failed"
