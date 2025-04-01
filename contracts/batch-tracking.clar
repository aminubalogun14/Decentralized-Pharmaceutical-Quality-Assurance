;; Batch Tracking Contract
;; Monitors medications through distribution chain

(define-data-var admin principal tx-sender)

;; Structure for batch tracking
(define-map batches (string-ascii 50)
  {
    manufacturer: principal,
    product-id: (string-ascii 50),
    production-date: uint,
    quantity: uint,
    current-owner: principal,
    status: (string-ascii 20)
  }
)

;; Track batch transfers
(define-map batch-history (tuple (batch-id (string-ascii 50)) (index uint))
  {
    from: principal,
    to: principal,
    timestamp: uint,
    location: (string-ascii 100),
    notes: (string-utf8 200)
  }
)

;; Counter for batch history entries
(define-map batch-history-count (string-ascii 50) uint)

;; Register a new batch - simplified without contract calls
(define-public (register-batch
    (batch-id (string-ascii 50))
    (product-id (string-ascii 50))
    (quantity uint))
  (let ((manufacturer tx-sender))
    ;; Simplified: No verification checks, just register the batch
    (map-set batch-history-count batch-id u0)
    (ok (map-set batches batch-id
      {
        manufacturer: manufacturer,
        product-id: product-id,
        production-date: block-height,
        quantity: quantity,
        current-owner: manufacturer,
        status: "active"
      }
    ))
  )
)

;; Transfer batch ownership
(define-public (transfer-batch
    (batch-id (string-ascii 50))
    (new-owner principal)
    (location (string-ascii 100))
    (notes (string-utf8 200)))
  (let ((current-batch (unwrap! (map-get? batches batch-id) (err u404))))
    (asserts! (is-eq (get current-owner current-batch) tx-sender) (err u403))
    (asserts! (is-eq (get status current-batch) "active") (err u405))

    ;; Update batch history
    (let ((history-index (default-to u0 (map-get? batch-history-count batch-id))))
      (map-set batch-history (tuple (batch-id batch-id) (index history-index))
        {
          from: tx-sender,
          to: new-owner,
          timestamp: block-height,
          location: location,
          notes: notes
        }
      )
      (map-set batch-history-count batch-id (+ history-index u1))
    )

    ;; Update current owner
    (ok (map-set batches batch-id
      (merge current-batch { current-owner: new-owner })
    ))
  )
)

;; Get batch details
(define-read-only (get-batch-details (batch-id (string-ascii 50)))
  (map-get? batches batch-id)
)

;; Get batch history entry
(define-read-only (get-batch-history-entry (batch-id (string-ascii 50)) (index uint))
  (map-get? batch-history (tuple (batch-id batch-id) (index index)))
)

;; Get batch history count
(define-read-only (get-batch-history-count (batch-id (string-ascii 50)))
  (default-to u0 (map-get? batch-history-count batch-id))
)

;; Mark batch as expired
(define-public (mark-batch-expired (batch-id (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? batches batch-id)
      batch-data (ok (map-set batches batch-id
        (merge batch-data { status: "expired" })))
      (err u404)
    )
  )
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)

