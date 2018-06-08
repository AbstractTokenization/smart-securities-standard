---
version: 0.1.1
---

OpenFinance S3 - Smart Securities Standard
==

This library contains contracts which reify particular SEC rules and
exemptions, such as regulations A+, CF, D, and S.  The library architecture
makes it possible for securities issuers to automate compliance with the SEC
rules governing their class of securities, and to roll over into other classes
as and when the rules allow. 

Contributing
--

If you would like to contribute, please see `contributing.md` before you begin.
Then, take a look at the setup instructions below.

Contract overview 
--

### Interfaces

- `TransferRestrictor`:  A contract expressing rules about whether to approve or
  block an ERC token transfer should implement this interface.  The contract
  may use the information available at call time (value sender, value receiver,
  and amount) as well as any additional information exposed through some
  interface of the calling contract.
- `UserChecker`:  Contracts which determine whether or not to block an account
  from doing something should implement this interface. 

### Concrete contracts

- `CapTables`:  This contract maintains cap tables for a set of securities
  identified by an integer index.  Each security is associated to an address,
  which should be an ERC20 contract implementing the appropriate transfer
  logic.
- `RestrictedTokenLogic`:  This contract extends Open Zeppelin's ERC20
  `StandardToken` contract, by allowing a `TransferRestrictor` to be configured
  which is used to enforce some rule set.
- `SimpleUserChecker`:  This contract implements the `UserChecker` interface.
  It maintains a configurable list of agents who may confirm users by storing a
  commitment (presumably a hash digest of a document) to user data.
- `TheRegD506c`:  This contract implements regulation D 506 (c) rules.  To use
  this as their `TransferRestrictor`, tokens must configure an AML/KYC provider
  and an accredited investor status checker for themselves.  These contracts
  must implement `UserChecker`.  Furthermore, the token contract must implement
  `RegD506cToken`.
- `ARegD506cToken`:  This contract implements the `RegD506cToken` interface,
  which requires internal tracking of the number of active shareholders.  A
  given shareholder may have multiple Ethereum accounts, but in this draft of
  the standard we actually restrict the number of accounts that have a positive
  balance.  _Note: An attacker may be able to DoS the investment community by
  buying shares under multiple accounts and exhausting the account allotment._
- `TokenFront`:  In order to provide a single contract address where users can
  send `ERC20` calls, a security should have a `TokenFront` which calls into
  one or more other contracts which implement the rule check, keep relevant
  state, etc. 

How to use the contracts
--

Issuance proceeds in several stages.

- **Stage I.** Choose a deployed `CapTables` contract and send a transaction
  which calls `initialize` with your total supply.  This will create a new
  security, owned by the caller and will give you the index of the security.
  The caller will hold the entire balance.
- **Stage II.**  Make calls to `CapTables.allocate` to configure the initial
  distribution of your security.
- **Stage III.**  Deploy a contract such as `ARegD506cToken` or `ARegSToken`
  that implements the ruleset you wish to apply.  These contracts require the
  `CapTable` instance and security index as part of the initial configuration.
  Now, call `migrate` to transfer control over the cap table to the token
  contract.
- **Stage IV.**  If you need to modify the rules that govern token transfers,
  call `migrate` on the token contract with the address of the contract with
  the new transfer controls.

Implemented Regulations
==
RegD 506 (c)
--

A security which meets this exemption may be traded under the following 
conditions.

- An initial shareholder may transfer shares _after_ a 12 month holding period.
- Both the buyer and seller in a share transfer must meet AML-KYC requirements.
- The buyer must be accredited.
- If the security was issued by a fund, the number of shareholders must not
	exceed 99; otherwise the number of shareholders must not exceed 2000.

Reg S
--

This regulation covers certain securities that can be traded by foreign investors.

- Both the seller and buyer must pass AML/KYC checks.
- Both the seller and buyer must reside in a non-US jursidiction.

Moving value into and out of S3
==
We provide the contracts `Importer.sol` and `Exporter.sol` in order to make it
easy to move value between S3 and other frameworks.

Setting up S3 for development
==

WIP
