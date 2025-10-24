;; WoodwindSymphony - Elite Clarinet Orchestra Platform
;; A blockchain-based platform for clarinet orchestral performance tracking, concert participation,
;; and symphonic community excellence

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))

;; Token constants
(define-constant token-name "WoodwindSymphony Crescendo Token")
(define-constant token-symbol "WCT")
(define-constant token-decimals u6)
(define-constant token-max-supply u50000000000) ;; 50k tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-rehearsal u3200000) ;; 3.2 WCT
(define-constant reward-concert u7500000) ;; 7.5 WCT
(define-constant reward-excellence u18000000) ;; 18.0 WCT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-concert-id uint u1)
(define-data-var next-rehearsal-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Orchestral profiles
(define-map orchestral-profiles
  principal
  {
    performer-name: (string-ascii 16),
    chair-position: (string-ascii 14), ;; "first-chair", "second-chair", "third-chair", "section"
    rehearsals-attended: uint,
    concerts-conducted: uint,
    total-performance: uint,
    musical-excellence: uint, ;; 1-5
    audition-date: uint
  }
)

;; Symphony concerts
(define-map symphony-concerts
  uint
  {
    concert-title: (string-ascii 10),
    composer: (string-ascii 9), ;; "mozart", "brahms", "debussy", "copland"
    complexity: (string-ascii 7), ;; "novice", "skilled", "expert", "master"
    duration: uint, ;; minutes
    tempo-marking: uint, ;; BPM
    max-performers: uint,
    conductor: principal,
    rehearsal-count: uint,
    symphony-rating: uint ;; average symphony
  }
)

;; Orchestra rehearsals
(define-map orchestra-rehearsals
  uint
  {
    concert-id: uint,
    performer: principal,
    piece-rehearsed: (string-ascii 9),
    rehearsal-time: uint, ;; minutes
    tempo-practiced: uint, ;; BPM
    pitch-accuracy: uint, ;; 1-5
    ensemble-blend: uint, ;; 1-5
    musical-phrasing: uint, ;; 1-5
    rehearsal-memo: (string-ascii 14),
    rehearsal-date: uint,
    symphonic: bool
  }
)

;; Concert critiques
(define-map concert-critiques
  { concert-id: uint, critic: principal }
  {
    score: uint, ;; 1-10
    critique-text: (string-ascii 14),
    conducting-style: (string-ascii 6), ;; "superb", "solid", "decent", "weak"
    critique-date: uint,
    acclaim-votes: uint
  }
)

;; Orchestral excellences
(define-map orchestral-excellences
  { performer: principal, excellence: (string-ascii 14) }
  {
    excellence-date: uint,
    rehearsal-total: uint
  }
)

;; Helper function to get or create profile
(define-private (get-or-create-profile (performer principal))
  (match (map-get? orchestral-profiles performer)
    profile profile
    {
      performer-name: "",
      chair-position: "section",
      rehearsals-attended: u0,
      concerts-conducted: u0,
      total-performance: u0,
      musical-excellence: u1,
      audition-date: stacks-block-height
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

;; Create symphony concert
(define-public (create-concert (concert-title (string-ascii 10)) (composer (string-ascii 9)) (complexity (string-ascii 7)) (duration uint) (tempo-marking uint) (max-performers uint))
  (let (
    (concert-id (var-get next-concert-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len concert-title) u0) err-invalid-input)
    (asserts! (> duration u0) err-invalid-input)
    (asserts! (and (>= tempo-marking u60) (<= tempo-marking u160)) err-invalid-input)
    (asserts! (> max-performers u0) err-invalid-input)
    
    (map-set symphony-concerts concert-id {
      concert-title: concert-title,
      composer: composer,
      complexity: complexity,
      duration: duration,
      tempo-marking: tempo-marking,
      max-performers: max-performers,
      conductor: tx-sender,
      rehearsal-count: u0,
      symphony-rating: u0
    })
    
    ;; Update profile
    (map-set orchestral-profiles tx-sender
      (merge profile {concerts-conducted: (+ (get concerts-conducted profile) u1)})
    )
    
    ;; Award concert creation tokens
    (try! (mint-tokens tx-sender reward-concert))
    
    (var-set next-concert-id (+ concert-id u1))
    (print {action: "concert-created", concert-id: concert-id, conductor: tx-sender})
    (ok concert-id)
  )
)

;; Log orchestra rehearsal
(define-public (log-rehearsal (concert-id uint) (piece-rehearsed (string-ascii 9)) (rehearsal-time uint) (tempo-practiced uint) (pitch-accuracy uint) (ensemble-blend uint) (musical-phrasing uint) (rehearsal-memo (string-ascii 14)) (symphonic bool))
  (let (
    (rehearsal-id (var-get next-rehearsal-id))
    (concert (unwrap! (map-get? symphony-concerts concert-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> rehearsal-time u0) err-invalid-input)
    (asserts! (and (>= tempo-practiced u45) (<= tempo-practiced u180)) err-invalid-input)
    (asserts! (and (>= pitch-accuracy u1) (<= pitch-accuracy u5)) err-invalid-input)
    (asserts! (and (>= ensemble-blend u1) (<= ensemble-blend u5)) err-invalid-input)
    (asserts! (and (>= musical-phrasing u1) (<= musical-phrasing u5)) err-invalid-input)
    
    (map-set orchestra-rehearsals rehearsal-id {
      concert-id: concert-id,
      performer: tx-sender,
      piece-rehearsed: piece-rehearsed,
      rehearsal-time: rehearsal-time,
      tempo-practiced: tempo-practiced,
      pitch-accuracy: pitch-accuracy,
      ensemble-blend: ensemble-blend,
      musical-phrasing: musical-phrasing,
      rehearsal-memo: rehearsal-memo,
      rehearsal-date: stacks-block-height,
      symphonic: symphonic
    })
    
    ;; Update concert stats if symphonic
    (if symphonic
      (let (
        (new-rehearsal-count (+ (get rehearsal-count concert) u1))
        (current-symphony (* (get symphony-rating concert) (get rehearsal-count concert)))
        (symphony-value (/ (+ pitch-accuracy ensemble-blend musical-phrasing) u3))
        (new-symphony-rating (/ (+ current-symphony symphony-value) new-rehearsal-count))
      )
        (map-set symphony-concerts concert-id
          (merge concert {
            rehearsal-count: new-rehearsal-count,
            symphony-rating: new-symphony-rating
          })
        )
        true
      )
      true
    )
    
    ;; Update profile
    (if symphonic
      (begin
        (map-set orchestral-profiles tx-sender
          (merge profile {
            rehearsals-attended: (+ (get rehearsals-attended profile) u1),
            total-performance: (+ (get total-performance profile) (/ rehearsal-time u60)),
            musical-excellence: (+ (get musical-excellence profile) (/ pitch-accuracy u18))
          })
        )
        (try! (mint-tokens tx-sender reward-rehearsal))
        true
      )
      (begin
        (try! (mint-tokens tx-sender (/ reward-rehearsal u6)))
        true
      )
    )
    
    (var-set next-rehearsal-id (+ rehearsal-id u1))
    (print {action: "rehearsal-logged", rehearsal-id: rehearsal-id, concert-id: concert-id})
    (ok rehearsal-id)
  )
)

;; Write concert critique
(define-public (write-critique (concert-id uint) (score uint) (critique-text (string-ascii 14)) (conducting-style (string-ascii 6)))
  (let (
    (concert (unwrap! (map-get? symphony-concerts concert-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (and (>= score u1) (<= score u10)) err-invalid-input)
    (asserts! (> (len critique-text) u0) err-invalid-input)
    (asserts! (is-none (map-get? concert-critiques {concert-id: concert-id, critic: tx-sender})) err-already-exists)
    
    (map-set concert-critiques {concert-id: concert-id, critic: tx-sender} {
      score: score,
      critique-text: critique-text,
      conducting-style: conducting-style,
      critique-date: stacks-block-height,
      acclaim-votes: u0
    })
    
    (print {action: "critique-written", concert-id: concert-id, critic: tx-sender})
    (ok true)
  )
)

;; Vote acclaim for critique
(define-public (vote-acclaim (concert-id uint) (critic principal))
  (let (
    (critique (unwrap! (map-get? concert-critiques {concert-id: concert-id, critic: critic}) err-not-found))
  )
    (asserts! (not (is-eq tx-sender critic)) err-unauthorized)
    
    (map-set concert-critiques {concert-id: concert-id, critic: critic}
      (merge critique {acclaim-votes: (+ (get acclaim-votes critique) u1)})
    )
    
    (print {action: "critique-acclaimed", concert-id: concert-id, critic: critic})
    (ok true)
  )
)

;; Update chair position
(define-public (update-chair-position (new-chair-position (string-ascii 14)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-chair-position) u0) err-invalid-input)
    
    (map-set orchestral-profiles tx-sender (merge profile {chair-position: new-chair-position}))
    
    (print {action: "chair-position-updated", performer: tx-sender, position: new-chair-position})
    (ok true)
  )
)

;; Claim excellence
(define-public (claim-excellence (excellence (string-ascii 14)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (is-none (map-get? orchestral-excellences {performer: tx-sender, excellence: excellence})) err-already-exists)
    
    ;; Check excellence requirements
    (let (
      (excellence-earned
        (if (is-eq excellence "principal-player") (>= (get rehearsals-attended profile) u60)
        (if (is-eq excellence "maestro-conductor") (>= (get concerts-conducted profile) u10)
        false)))
    )
      (asserts! excellence-earned err-unauthorized)
      
      ;; Record excellence
      (map-set orchestral-excellences {performer: tx-sender, excellence: excellence} {
        excellence-date: stacks-block-height,
        rehearsal-total: (get rehearsals-attended profile)
      })
      
      ;; Award excellence tokens
      (try! (mint-tokens tx-sender reward-excellence))
      
      (print {action: "excellence-claimed", performer: tx-sender, excellence: excellence})
      (ok true)
    )
  )
)

;; Update performer name
(define-public (update-performer-name (new-performer-name (string-ascii 16)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-performer-name) u0) err-invalid-input)
    (map-set orchestral-profiles tx-sender (merge profile {performer-name: new-performer-name}))
    (print {action: "performer-name-updated", performer: tx-sender})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-orchestral-profile (performer principal))
  (map-get? orchestral-profiles performer)
)

(define-read-only (get-symphony-concert (concert-id uint))
  (map-get? symphony-concerts concert-id)
)

(define-read-only (get-orchestra-rehearsal (rehearsal-id uint))
  (map-get? orchestra-rehearsals rehearsal-id)
)

(define-read-only (get-concert-critique (concert-id uint) (critic principal))
  (map-get? concert-critiques {concert-id: concert-id, critic: critic})
)

(define-read-only (get-excellence (performer principal) (excellence (string-ascii 14)))
  (map-get? orchestral-excellences {performer: performer, excellence: excellence})
)