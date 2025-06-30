;; Fitness Rewards Platform
;; Incentivizing healthy behaviors through token rewards

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u900))
(define-constant err-unauthorized (err u901))
(define-constant err-goal-not-found (err u902))
(define-constant err-challenge-not-found (err u903))
(define-constant err-insufficient-rewards (err u904))
(define-constant err-already-completed (err u905))

(define-data-var goal-counter uint u0)
(define-data-var challenge-counter uint u0)
(define-data-var reward-pool uint u0)

(define-map user-profiles principal {
  name: (string-ascii 100),
  age: uint,
  fitness-level: (string-ascii 20),
  goals: (string-ascii 200),
  total-points: uint,
  tokens-earned: uint,
  joined-at: uint
})

(define-map fitness-goals uint {
  user: principal,
  goal-type: (string-ascii 50), ;; steps, calories, workout-minutes, weight-loss
  target-value: uint,
  current-value: uint,
  deadline: uint,
  reward-amount: uint,
  completed: bool,
  verified: bool
})

(define-map fitness-challenges uint {
  name: (string-ascii 100),
  description: (string-ascii 300),
  challenge-type: (string-ascii 50),
  target-value: uint,
  duration: uint,
  prize-pool: uint,
  participants: uint,
  max-participants: uint,
  start-time: uint,
  end-time: uint,
  active: bool
})

(define-map challenge-participants {challenge-id: uint, user: principal} {
  joined-at: uint,
  current-progress: uint,
  completed: bool,
  rank: uint
})

(define-map activity-logs {user: principal, date: uint} {
  steps: uint,
  calories-burned: uint,
  workout-minutes: uint,
  heart-rate-avg: uint,
  verified: bool
})

(define-map fitness-trainers principal {
  name: (string-ascii 100),
  certification: (string-ascii 100),
  specialization: (string-ascii 100),
  hourly-rate: uint,
  rating: uint,
  verified: bool
})

(define-read-only (get-user-profile (user principal))
  (map-get? user-profiles user)
)

(define-read-only (get-fitness-goal (goal-id uint))
  (map-get? fitness-goals goal-id)
)

(define-read-only (get-fitness-challenge (challenge-id uint))
  (map-get? fitness-challenges challenge-id)
)

(define-read-only (get-challenge-participation (challenge-id uint) (user principal))
  (map-get? challenge-participants {challenge-id: challenge-id, user: user})
)

(define-read-only (get-activity-log (user principal) (date uint))
  (map-get? activity-logs {user: user, date: date})
)

(define-read-only (get-trainer-info (trainer principal))
  (map-get? fitness-trainers trainer)
)

(define-public (create-user-profile (name (string-ascii 100)) (age uint) (fitness-level (string-ascii 20)) (goals (string-ascii 200)))
  (begin
    (map-set user-profiles tx-sender {
      name: name,
      age: age,
      fitness-level: fitness-level,
      goals: goals,
      total-points: u0,
      tokens-earned: u0,
      joined-at: block-height
    })
    (ok true)
  )
)

(define-public (register-trainer (name (string-ascii 100)) (certification (string-ascii 100)) (specialization (string-ascii 100)) (rate uint))
  (begin
    (map-set fitness-trainers tx-sender {
      name: name,
      certification: certification,
      specialization: specialization,
      hourly-rate: rate,
      rating: u0,
      verified: false
    })
    (ok true)
  )
)

(define-public (verify-trainer (trainer principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let ((trainer-info (unwrap! (get-trainer-info trainer) err-unauthorized)))
      (map-set fitness-trainers trainer (merge trainer-info {verified: true}))
      (ok true)
    )
  )
)

(define-public (set-fitness-goal (goal-type (string-ascii 50)) (target-value uint) (deadline uint) (reward-amount uint))
  (let ((user-profile (unwrap! (get-user-profile tx-sender) err-unauthorized))
        (goal-id (+ (var-get goal-counter) u1)))
    
    (asserts! (> target-value u0) (err u906))
    (asserts! (> deadline block-height) (err u907))
    
    (map-set fitness-goals goal-id {
      user: tx-sender,
      goal-type: goal-type,
      target-value: target-value,
      current-value: u0,
      deadline: deadline,
      reward-amount: reward-amount,
      completed: false,
      verified: false
    })
    
    (var-set goal-counter goal-id)
    (ok goal-id)
  )
)

(define-public (log-activity (date uint) (steps uint) (calories uint) (workout-minutes uint) (heart-rate uint))
  (let ((user-profile (unwrap! (get-user-profile tx-sender) err-unauthorized)))
    (map-set activity-logs {user: tx-sender, date: date} {
      steps: steps,
      calories-burned: calories,
      workout-minutes: workout-minutes,
      heart-rate-avg: heart-rate,
      verified: false
    })
    (ok true)
  )
)

(define-public (verify-activity (user principal) (date uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let ((activity (unwrap! (get-activity-log user date) err-unauthorized)))
      (map-set activity-logs {user: user, date: date} (merge activity {verified: true}))
      (ok true)
    )
  )
)

(define-public (update-goal-progress (goal-id uint) (new-value uint))
  (let ((goal (unwrap! (get-fitness-goal goal-id) err-goal-not-found))
        (user-profile (unwrap! (get-user-profile tx-sender) err-unauthorized)))
    
    (asserts! (is-eq tx-sender (get user goal)) err-unauthorized)
    (asserts! (not (get completed goal)) err-already-completed)
    
    (let ((updated-goal (merge goal {current-value: new-value})))
      (map-set fitness-goals goal-id updated-goal)
      
      ;; Check if goal is completed
      (if (>= new-value (get target-value goal))
        (begin
          (map-set fitness-goals goal-id (merge updated-goal {completed: true}))
          ;; Award points
          (map-set user-profiles tx-sender (merge user-profile {
            total-points: (+ (get total-points user-profile) (get reward-amount goal))
          }))
        )
        false
      )
    )
    (ok true)
  )
)

(define-public (create-challenge (name (string-ascii 100)) (description (string-ascii 300)) (challenge-type (string-ascii 50)) (target uint) (duration uint) (prize-pool uint) (max-participants uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (let ((challenge-id (+ (var-get challenge-counter) u1)))
      
      (map-set fitness-challenges challenge-id {
        name: name,
        description: description,
        challenge-type: challenge-type,
        target-value: target,
        duration: duration,
        prize-pool: prize-pool,
        participants: u0,
        max-participants: max-participants,
        start-time: block-height,
        end-time: (+ block-height duration),
        active: true
      })
      
      (var-set challenge-counter challenge-id)
      (ok challenge-id)
    )
  )
)

(define-public (join-challenge (challenge-id uint))
  (let ((challenge (unwrap! (get-fitness-challenge challenge-id) err-challenge-not-found))
        (user-profile (unwrap! (get-user-profile tx-sender) err-unauthorized)))
    
    (asserts! (get active challenge) err-challenge-not-found)
    (asserts! (< (get participants challenge) (get max-participants challenge)) (err u908))
    (asserts! (< block-height (get end-time challenge)) (err u909))
    
    (map-set challenge-participants {challenge-id: challenge-id, user: tx-sender} {
      joined-at: block-height,
      current-progress: u0,
      completed: false,
      rank: u0
    })
    
    (map-set fitness-challenges challenge-id (merge challenge {
      participants: (+ (get participants challenge) u1)
    }))
    
    (ok true)
  )
)

(define-public (update-challenge-progress (challenge-id uint) (progress uint))
  (let ((challenge (unwrap! (get-fitness-challenge challenge-id) err-challenge-not-found))
        (participation (unwrap! (get-challenge-participation challenge-id tx-sender) err-unauthorized)))
    
    (asserts! (get active challenge) err-challenge-not-found)
    (asserts! (< block-height (get end-time challenge)) (err u909))
    
    (map-set challenge-participants {challenge-id: challenge-id, user: tx-sender} 
             (merge participation {current-progress: progress}))
    
    ;; Check if challenge target is met
    (if (>= progress (get target-value challenge))
      (map-set challenge-participants {challenge-id: challenge-id, user: tx-sender}
               (merge participation {current-progress: progress, completed: true}))
      false
    )
    
    (ok true)
  )
)

(define-public (claim-rewards (goal-id uint))
  (let ((goal (unwrap! (get-fitness-goal goal-id) err-goal-not-found))
        (user-profile (unwrap! (get-user-profile tx-sender) err-unauthorized)))
    
    (asserts! (is-eq tx-sender (get user goal)) err-unauthorized)
    (asserts! (get completed goal) err-unauthorized)
    (asserts! (get verified goal) err-unauthorized)
    (asserts! (>= (var-get reward-pool) (get reward-amount goal)) err-insufficient-rewards)
    
    ;; Transfer reward tokens
    (try! (as-contract (stx-transfer? (get reward-amount goal) tx-sender (get user goal))))
    
    ;; Update user profile
    (map-set user-profiles tx-sender (merge user-profile {
      tokens-earned: (+ (get tokens-earned user-profile) (get reward-amount goal))
    }))
    
    ;; Update reward pool
    (var-set reward-pool (- (var-get reward-pool) (get reward-amount goal)))
    
    (ok (get reward-amount goal))
  )
)

(define-public (fund-reward-pool (amount uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set reward-pool (+ (var-get reward-pool) amount))
    (ok true)
  )
)
