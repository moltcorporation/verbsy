"use client";

import { useState } from "react";

export function AppStoreModalButton() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <button className="store-button" type="button" onClick={() => setIsOpen(true)}>
        <span className="store-button-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24" role="img">
            <path d="M17.44 13.08c-.02-2.12 1.73-3.15 1.81-3.2-1-.14-1.96-.63-2.66-1.37-.7-.74-1.08-1.7-1.06-2.71.03-1.2.67-2.28 1.7-2.88-.83-.02-1.82.55-2.39 1.24-.52.63-.98 1.65-.85 2.62.9.07 1.77-.46 2.33-1.12.56-.65.94-1.57 1.12-2.58h.03c.84.05 1.67.39 2.29.96.62.57 1.02 1.35 1.08 2.19.09 1.2-.41 2.33-1.33 3.09.9.49 1.55 1.37 1.8 2.39.25 1.02.07 2.1-.49 2.99-.58.9-1.36 1.91-2.33 1.93-.93.02-1.24-.58-2.31-.58-1.07 0-1.42.56-2.3.6-.94.04-1.65-.96-2.23-1.85-1.22-1.89-2.15-5.33-.9-7.65.6-1.13 1.67-1.86 2.84-1.88.9-.02 1.75.61 2.31.61.54 0 1.55-.75 2.62-.64.45.02 1.72.18 2.53 1.37-.07.04-1.52.9-1.5 2.68.02 2.13 1.87 2.84 1.89 2.85-.02.05-.3 1.04-.98 2.06-.6.9-1.22 1.78-2.21 1.8-.96.02-1.27-.58-2.37-.58-1.1 0-1.44.56-2.35.6-.95.04-1.68-.96-2.3-1.84-1.26-1.82-2.24-5.14-.94-7.4.63-1.1 1.76-1.8 2.99-1.82.93-.02 1.82.63 2.39.63.58 0 1.67-.78 2.82-.67.48.02 1.82.19 2.68 1.46-.07.04-1.61.94-1.59 2.81Z" />
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
              Verbsy for iPhone is being prepared for the App Store. The web
              API and launch page are live now.
            </p>
          </div>
        </div>
      )}
    </>
  );
}
