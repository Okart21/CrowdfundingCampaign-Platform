;; ArtAuction Hub: Decentralized digital art auction platform with curator validation
;; Enables artists to list artworks, collectors to bid, and curators to authenticate pieces

(define-data-var chief-curator principal tx-sender)

(define-map artwork-registry
  { artwork-id: uint }
  {
    artist: principal,
    reserve-price: uint,
    artwork-title: (string-ascii 50),
    artwork-description: (string-ascii 500),
    auction-duration: uint,
    authenticated: bool
  })

(define-map bidding-history
  { artwork-id: uint, bid-id: uint }
  {
    bidder: principal,
    bid-timestamp: uint,
    bid-status: (string-ascii 20)
  })

(define-data-var next-artwork-id uint u1)

(define-map bid-tracker
  { artwork-id: uint }
  { total-bids: uint })

;; List a new artwork for auction
(define-public (list-artwork (title-input (string-ascii 50)) (description-input (string-ascii 500)) (duration-input uint) (reserve-input uint))
  (let
    (
      (artwork-id (var-get next-artwork-id))
      (bid-id u0)
      (title title-input)
      (description description-input)
      (duration duration-input)
      (reserve reserve-input)
    )
    ;; Input validation
    (asserts! (> reserve u0) (err u1))
    (asserts! (> (len title) u0) (err u5))
    (asserts! (> (len description) u0) (err u6))
    (asserts! (> duration u0) (err u7))
    
    (map-set artwork-registry
      { artwork-id: artwork-id }
      {
        artist: tx-sender,
        reserve-price: reserve,
        artwork-title: title,
        artwork-description: description,
        auction-duration: duration,
        authenticated: false
      }
    )
    (map-set bidding-history
      { artwork-id: artwork-id, bid-id: bid-id }
      {
        bidder: tx-sender,
        bid-timestamp: artwork-id,
        bid-status: "listed"
      }
    )
    (map-set bid-tracker
      { artwork-id: artwork-id }
      { total-bids: u1 }
    )
    (var-set next-artwork-id (+ artwork-id u1))
    (ok artwork-id)
  ))

;; Place a bid on artwork
(define-public (place-bid (artwork-id-input uint))
  (let
    (
      (artwork-id artwork-id-input)
      (artwork-info (unwrap! (map-get? artwork-registry { artwork-id: artwork-id }) (err u2)))
      (reserve (get reserve-price artwork-info))
      (artist (get artist artwork-info))
      (bid-data (default-to { total-bids: u0 } (map-get? bid-tracker { artwork-id: artwork-id })))
      (bid-id (get total-bids bid-data))
      (new-bid-id (+ bid-id u1))
    )
    ;; Input validation
    (asserts! (> artwork-id u0) (err u8))
    (asserts! (not (is-eq tx-sender artist)) (err u3))
    
    (try! (stx-transfer? reserve tx-sender artist))
    (map-set bidding-history
      { artwork-id: artwork-id, bid-id: bid-id }
      {
        bidder: tx-sender,
        bid-timestamp: (var-get next-artwork-id),
        bid-status: "placed"
      }
    )
    (map-set bid-tracker
      { artwork-id: artwork-id }
      { total-bids: new-bid-id }
    )
    (ok true)
  ))

;; Authenticate artwork (chief curator only)
(define-public (authenticate-artwork (artwork-id-input uint))
  (let
    (
      (artwork-id artwork-id-input)
      (artwork-info (unwrap! (map-get? artwork-registry { artwork-id: artwork-id }) (err u2)))
      (bid-data (default-to { total-bids: u0 } (map-get? bid-tracker { artwork-id: artwork-id })))
      (bid-id (get total-bids bid-data))
      (new-bid-id (+ bid-id u1))
    )
    ;; Input validation
    (asserts! (> artwork-id u0) (err u8))
    (asserts! (is-eq tx-sender (var-get chief-curator)) (err u4))
    
    (map-set artwork-registry
      { artwork-id: artwork-id }
      (merge artwork-info { authenticated: true })
    )
    (map-set bidding-history
      { artwork-id: artwork-id, bid-id: bid-id }
      {
        bidder: (get artist artwork-info),
        bid-timestamp: (var-get next-artwork-id),
        bid-status: "authenticated"
      }
    )
    (map-set bid-tracker
      { artwork-id: artwork-id }
      { total-bids: new-bid-id }
    )
    (ok true)
  ))

;; Get artwork details
(define-read-only (get-artwork (artwork-id uint))
  (map-get? artwork-registry { artwork-id: artwork-id }))

;; Get bidding history entry
(define-read-only (get-bid-history (artwork-id uint) (bid-id uint))
  (map-get? bidding-history { artwork-id: artwork-id, bid-id: bid-id }))

;; Get total bids for artwork
(define-read-only (get-bid-count (artwork-id uint))
  (let
    (
      (bid-data (default-to { total-bids: u0 } (map-get? bid-tracker { artwork-id: artwork-id })))
    )
    (get total-bids bid-data)
  ))
