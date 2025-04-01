;; Manufacturer Verification Contract
;; This contract validates legitimate drug producers

(define-data-var admin principal tx-sender)

;; Map of verified manufacturers
(define-map verified-manufacturers principal
  {
    name: (string-ascii 100),
    license-id: (string-ascii 50),
    verified-at: uint,
    status: (string-ascii 10)
  }
)

;; Add a new manufacturer
(define-public (register-manufacturer (name (string-ascii 100)) (license-id (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set verified-manufacturers tx-sender
      {
        name: name,
        license-id: license-id,
        verified-at: block-height,
        status: "pending"
      }
    ))
  )
)

;; Verify a manufacturer
(define-public (verify-manufacturer (manufacturer-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? verified-manufacturers manufacturer-address)
      manufacturer-data (ok (map-set verified-manufacturers manufacturer-address
        (merge manufacturer-data { status: "verified" })))
      (err u404)
    )
  )
)

;; Revoke a manufacturer's verification
(define-public (revoke-manufacturer (manufacturer-address principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? verified-manufacturers manufacturer-address)
      manufacturer-data (ok (map-set verified-manufacturers manufacturer-address
        (merge manufacturer-data { status: "revoked" })))
      (err u404)
    )
  )
)

;; Check if a manufacturer is verified
(define-read-only (is-verified (manufacturer-address principal))
  (match (map-get? verified-manufacturers manufacturer-address)
    manufacturer-data (is-eq (get status manufacturer-data) "verified")
    false
  )
)

;; Get manufacturer details
(define-read-only (get-manufacturer-details (manufacturer-address principal))
  (map-get? verified-manufacturers manufacturer-address)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
