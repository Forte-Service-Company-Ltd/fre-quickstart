1. create the policy

```bash
npx tsx index.ts setupPolicy vesting-policy.json

export POLICY_ID=3
```

2. check the trackers

```bash
npx tsx updateMappedTracker.ts getAllTrackers $POLICY_ID
```

returns:

```bash
➜  fre-quickstart git:(main) ✗ npx tsx updateMappedTracker.ts getAllTrackers 3
{
  accounts: [ '0xE4F53F8aD1EB9B8A556ccF363a2389D59447a6df' ],
  chainId: 84532
}
[
  {
    set: true,
    pType: 2,
    mapped: true,
    trackerKeyType: 0,
    trackerValue: '0x0000000000000000000000000000000000000000000000000000000000000000',
    trackerIndex: 1n
  },
  {
    set: true,
    pType: 2,
    mapped: true,
    trackerKeyType: 0,
    trackerValue: '0x0000000000000000000000000000000000000000000000000000000000000000',
    trackerIndex: 2n
  }
]
```

3. update a mapped tracker

```bash
npx tsx updateMappedTracker.ts updateMappedTracker $POLICY_ID 1
```

result:

```bash
➜  fre-quickstart git:(main) ✗ npx tsx updateMappedTracker.ts updateMappedTracker 3 1
{
  accounts: [ '0xE4F53F8aD1EB9B8A556ccF363a2389D59447a6df' ],
  chainId: 84532
}
{"Name":"VestAmount","KeyType":"address","ValueType":"uint256","InitialKeys":["0x1234567890123456789012345678901234567890"],"InitialValues":["1000000000000000000"]}
{
  trackerId: 1,
  transactionHash: '0xeeb94808548f4d380d1ad05448cee808f862c7429d96db894d63ca2fdfd63838'
}
Mapped tracker updated!
```

4. get the value of that updated mapped tracker

```bash
npx tsx updateMappedTracker.ts getMappedTrackerValue $POLICY_ID 1 0x1234567890123456789012345678901234567890
```

result:

```bash
➜  fre-quickstart git:(main) ✗ npx tsx updateMappedTracker.ts getMappedTrackerValue $POLICY_ID 1 0x1234567890123456789012345678901234567890
{
  accounts: [ '0xE4F53F8aD1EB9B8A556ccF363a2389D59447a6df' ],
  chainId: 84532
}
0x
```
