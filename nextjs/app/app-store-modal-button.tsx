"use client";

import { useState } from "react";

export function AppStoreModalButton() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <button className="store-button" type="button" onClick={() => setIsOpen(true)}>
        <span className="store-button-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24" role="img">
            <path d="M16.1 12.7c0-1.9 1.55-2.82 1.62-2.86-.88-1.28-2.24-1.45-2.72-1.47-1.16-.12-2.25.68-2.84.68-.58 0-1.48-.66-2.44-.64-1.25.02-2.4.73-3.05 1.85-1.3 2.26-.33 5.62.94 7.45.62.9 1.36 1.9 2.34 1.86.94-.04 1.29-.6 2.42-.6s1.45.6 2.45.58c1.01-.02 1.65-.91 2.26-1.81.71-1.04 1-2.05 1.02-2.1-.02-.01-1.98-.76-2-2.94ZM14.25 7.15c.52-.63.87-1.51.77-2.39-.75.03-1.65.5-2.19 1.13-.48.56-.9 1.46-.79 2.32.84.06 1.69-.43 2.21-1.06Z" />
          </svg>
        </span>
        <span>
          <span className="store-button-kicker">Download on the</span>
          <span className="store-button-label">App Store</span>
        </span>
      </button>

      {isOpen && (
        <div
          className="modal-backdrop"
          role="presentation"
          onClick={() => setIsOpen(false)}
        >
          <div
            aria-modal="true"
            className="coming-soon-modal"
            role="dialog"
            onClick={(event) => event.stopPropagation()}
          >
            <button
              aria-label="Close"
              className="modal-close"
              type="button"
              onClick={() => setIsOpen(false)}
            >
              ×
            </button>
            <p className="eyebrow">iOS app</p>
            <h2>Coming soon</h2>
            <p>
              Verbsy for iPhone is being prepared for App Store launch. The
              download button will point here as soon as the listing is live.
            </p>
          </div>
        </div>
      )}
    </>
  );
}
