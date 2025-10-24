# WoodwindSymphony - Elite Clarinet Orchestra Platform

A blockchain-based platform built on Stacks that enables clarinet orchestral performers to track their musical journey, participate in symphonic concerts, and earn recognition through a tokenized reward system for orchestral excellence.

## Overview

WoodwindSymphony creates a decentralized ecosystem where classical musicians can:
- Log rehearsal sessions with detailed performance metrics
- Create and conduct symphony concerts
- Progress through orchestral chair positions
- Earn WCT (WoodwindSymphony Crescendo Token) rewards for participation
- Provide and receive performance critiques
- Claim excellence achievements for exceptional dedication
- Build a comprehensive orchestral performance portfolio

## Token Economics

**WoodwindSymphony Crescendo Token (WCT)**
- **Symbol**: WCT
- **Decimals**: 6
- **Max Supply**: 50,000 WCT (50,000,000,000 micro-tokens)

### Reward Structure
- **Symphonic Rehearsal**: 3.2 WCT (high-quality practice sessions)
- **Standard Rehearsal**: 0.53 WCT (regular practice sessions)
- **Concert Creation/Conducting**: 7.5 WCT
- **Excellence Achievement**: 18.0 WCT

## Core Features

### 1. Orchestral Profiles

Each performer maintains a comprehensive profile:
- **Performer Name**: Custom display name (up to 16 characters)
- **Chair Position**: Orchestra seating (first-chair, second-chair, third-chair, section)
- **Rehearsals Attended**: Total practice session count
- **Concerts Conducted**: Number of concerts organized
- **Total Performance**: Cumulative performance hours
- **Musical Excellence**: Skill rating (1-5 scale)
- **Audition Date**: Initial platform registration block height

### 2. Symphony Concerts

Conductors can create concert events with rich metadata:
- **Concert Title**: Event name (up to 10 characters)
- **Composer**: Featured composer (Mozart, Brahms, Debussy, Copland, etc.)
- **Complexity**: Difficulty level (novice, skilled, expert, master)
- **Duration**: Expected performance length in minutes
- **Tempo Marking**: BPM range (60-160 beats per minute)
- **Max Performers**: Orchestra capacity
- **Rehearsal Count**: Number of symphonic rehearsals logged
- **Symphony Rating**: Average quality score from all rehearsals

### 3. Orchestra Rehearsals

Performers log practice sessions with three-dimensional evaluation:
- **Pitch Accuracy**: Intonation and note precision (1-5)
- **Ensemble Blend**: Section integration and balance (1-5)
- **Musical Phrasing**: Artistic interpretation and expression (1-5)

A rehearsal is classified as **symphonic** (high-quality) when explicitly marked by the performer, typically indicating professional-level practice with full engagement across all three dimensions.

**Additional Tracking:**
- Piece rehearsed
- Rehearsal duration
- Tempo practiced (45-180 BPM)
- Performance notes/memos

### 4. Concert Critiques

Community members provide detailed performance feedback:
- **Score**: Overall concert quality (1-10 scale)
- **Critique Text**: Written review (up to 14 characters)
- **Conducting Style**: Leadership assessment (superb, solid, decent, weak)
- **Acclaim Votes**: Community endorsements of insightful critiques

### 5. Orchestral Excellence

Exceptional achievements unlock special recognitions:
- **Principal Player**: Attend 60+ symphonic rehearsals
- **Maestro Conductor**: Create and conduct 10+ concerts

## Contract Functions

### Public Functions

#### `create-concert`
```clarity
(create-concert 
  (concert-title (string-ascii 10)) 
  (composer (string-ascii 9)) 
  (complexity (string-ascii 7)) 
  (duration uint) 
  (tempo-marking uint) 
  (max-performers uint))
```
Creates a new symphony concert and awards 7.5 WCT to the conductor.

**Validations:**
- Concert title must be non-empty
- Duration must be positive
- Tempo marking must be between 60-160 BPM
- Max performers must be positive

#### `log-rehearsal`
```clarity
(log-rehearsal 
  (concert-id uint) 
  (piece-rehearsed (string-ascii 9)) 
  (rehearsal-time uint) 
  (tempo-practiced uint) 
  (pitch-accuracy uint) 
  (ensemble-blend uint) 
  (musical-phrasing uint) 
  (rehearsal-memo (string-ascii 14)) 
  (symphonic bool))
```
Records a rehearsal session. Awards 3.2 WCT for symphonic rehearsals, 0.53 WCT for standard.

**Validations:**
- Rehearsal time must be positive
- Tempo practiced: 45-180 BPM
- All quality metrics: 1-5 scale

#### `write-critique`
```clarity
(write-critique 
  (concert-id uint) 
  (score uint) 
  (critique-text (string-ascii 14)) 
  (conducting-style (string-ascii 6)))
```
Submits a concert critique. One critique per performer per concert.

**Validations:**
- Score: 1-10 scale
- Critique text must be non-empty
- Cannot duplicate critiques

#### `vote-acclaim`
```clarity
(vote-acclaim (concert-id uint) (critic principal))
```
Endorses a helpful critique. Cannot vote for your own critiques.

#### `update-chair-position`
```clarity
(update-chair-position (new-chair-position (string-ascii 14)))
```
Updates your orchestral seating position.

#### `claim-excellence`
```clarity
(claim-excellence (excellence (string-ascii 14)))
```
Claims an excellence achievement and receives 18.0 WCT reward.

**Requirements:**
- Principal Player: 60+ rehearsals attended
- Maestro Conductor: 10+ concerts conducted

#### `update-performer-name`
```clarity
(update-performer-name (new-performer-name (string-ascii 16)))
```
Updates your display name in the orchestra.

### Read-Only Functions

- `get-name()`: Returns token name
- `get-symbol()`: Returns token symbol  
- `get-decimals()`: Returns token decimals
- `get-balance(principal)`: Returns WCT balance for an address
- `get-orchestral-profile(principal)`: Retrieves performer profile
- `get-symphony-concert(uint)`: Retrieves concert details
- `get-orchestra-rehearsal(uint)`: Retrieves rehearsal session details
- `get-concert-critique(uint, principal)`: Retrieves specific critique
- `get-excellence(principal, string)`: Checks excellence achievement status

## Usage Examples

### Creating a Symphony Concert
```clarity
(contract-call? .woodwind-symphony create-concert 
  "SpringGala" 
  "mozart" 
  "expert" 
  u90 
  u120 
  u25)
```

### Logging a Symphonic Rehearsal
```clarity
(contract-call? .woodwind-symphony log-rehearsal 
  u1 
  "clarinet" 
  u75 
  u100 
  u5 
  u4 
  u5 
  "excellent flow" 
  true)
```

### Writing a Concert Critique
```clarity
(contract-call? .woodwind-symphony write-critique 
  u1 
  u9 
  "masterful lead" 
  "superb")
```

### Claiming Principal Player Excellence
```clarity
(contract-call? .woodwind-symphony claim-excellence 
  "principal-player")
```

## How Symphony Rating Works

The symphony rating is a dynamic metric that reflects the overall quality of rehearsals for a concert:

1. Each symphonic rehearsal contributes a quality score (average of pitch accuracy, ensemble blend, and musical phrasing)
2. The concert's symphony rating is the running average of all symphonic rehearsal quality scores
3. This creates an objective measure of rehearsal quality over time
4. Higher symphony ratings indicate better-prepared concerts

**Formula:**
```
symphony-value = (pitch-accuracy + ensemble-blend + musical-phrasing) / 3
new-symphony-rating = (previous-total + symphony-value) / new-rehearsal-count
```

## Musical Excellence Calculation

Performer skill grows incrementally with each symphonic rehearsal:
```clarity
musical-excellence = base-excellence + (pitch-accuracy / 18)
```

This means approximately 18 perfect-pitch rehearsals increase your excellence by 1 level.

## Error Codes

- `u100`: Owner-only function (not used in current implementation)
- `u101`: Resource not found (concert, rehearsal, or critique doesn't exist)
- `u102`: Resource already exists (duplicate critique or excellence claim)
- `u103`: Unauthorized action (voting for own critique)
- `u104`: Invalid input parameters (out-of-range values)

## Development

### Prerequisites
- Stacks blockchain development environment
- Clarity smart contract knowledge
- Clarinet for local testing and deployment

### Testing Strategy

**Unit Tests:**
```bash
clarinet test
```

Key test cases:
- Token minting respects maximum supply
- Rehearsal quality calculations are accurate
- Symphony rating updates correctly with each rehearsal
- Excellence requirements are properly validated
- One-critique-per-concert rule is enforced
- Tempo and quality metric ranges are validated

### Deployment
```bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet (after thorough testing)
clarinet deploy --mainnet
```

## Security Considerations

✅ **Implemented Safeguards:**
- All numeric inputs validated for valid ranges
- Concert existence checked before rehearsal logging
- Excellence claims validated against actual achievements
- Duplicate critique prevention
- Self-voting prevention for critiques
- Token supply cap enforced on all mints

⚠️ **Important Notes:**
- No token transfer functionality (tokens are earned, not traded)
- Chair positions are self-reported (trust-based system)
- "Symphonic" classification is performer-determined
- No time-lock mechanisms on progression

## Use Cases

### For Musicians
- **Portfolio Building**: Create comprehensive performance history on-chain
- **Skill Tracking**: Monitor musical excellence growth over time
- **Recognition**: Earn tokens and excellence achievements
- **Community**: Connect with other orchestral performers

### For Conductors
- **Concert Management**: Organize and track symphony performances
- **Rehearsal Oversight**: Monitor preparation quality via symphony ratings
- **Reputation**: Build conducting credentials through successful concerts

### For Music Organizations
- **Audition Reference**: Review candidate's verifiable performance history
- **Quality Metrics**: Objective assessment of rehearsal dedication
- **Community Engagement**: Foster active orchestral participation

## API Integration Example

```javascript
// Connect to Stacks blockchain
import { makeContractCall } from '@stacks/transactions';

// Log a rehearsal
const logRehearsalTx = await makeContractCall({
  contractAddress: 'SP2...',
  contractName: 'woodwind-symphony',
  functionName: 'log-rehearsal',
  functionArgs: [
    uintCV(1),              // concert-id
    stringAsciiCV('mozart'), // piece-rehearsed
    uintCV(60),             // rehearsal-time
    uintCV(120),            // tempo-practiced
    uintCV(5),              // pitch-accuracy
    uintCV(4),              // ensemble-blend
    uintCV(5),              // musical-phrasing
    stringAsciiCV('great'), // rehearsal-memo
    trueCV()                // symphonic
  ],
  senderKey: privateKey,
});
```

## Roadmap

### Phase 1 (Current)
- ✅ Core orchestral tracking functionality
- ✅ Token reward system
- ✅ Critique and acclaim features
- ✅ Excellence achievement system

### Phase 2 (Planned)
- [ ] Token transfer functionality
- [ ] NFT certificates for excellence achievements
- [ ] Concert performance recordings (IPFS integration)
- [ ] Time-based progression gates for chair positions
- [ ] Rehearsal scheduling and coordination

### Phase 3 (Future)
- [ ] Multi-instrument orchestra support
- [ ] Collaborative ensemble tracking
- [ ] Competition and audition features
- [ ] Integration with music education platforms
- [ ] DAO governance for platform evolution

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request with detailed description

## License

[Specify your license - MIT, Apache 2.0, etc.]

## Support

- **Documentation**: [Link to full docs]
- **Discord**: [Community server]
- **Twitter**: [@WoodwindSymphony]
- **Email**: support@woodwindsymphony.io

## Acknowledgments

Built with ❤️ for the classical music community. Special thanks to clarinet performers worldwide who inspired this platform.

---

**Smart Contract Address**: [Deployed contract address]  
**Network**: Stacks Blockchain  
**Language**: Clarity  
**Version**: 1.0.0
