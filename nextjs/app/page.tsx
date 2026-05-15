import { AppStoreModalButton } from "./app-store-modal-button";

const words = [
  {
    word: "Sonder",
    definition: "The realization that every person has a vivid inner life.",
  },
  {
    word: "Equanimity",
    definition: "Mental calm under stress.",
  },
  {
    word: "Aplomb",
    definition: "Confident composure in a difficult moment.",
  },
];

export default function Home() {
  return (
    <main className="site-shell">
      <nav className="site-nav" aria-label="Main navigation">
        <a className="brand-lockup" href="#top" aria-label="Verbsy home">
          <span className="brand-mark">V</span>
          <span>Verbsy</span>
        </a>
        <div className="nav-links">
          <a href="#features">Features</a>
          <a href="#widgets">Widgets</a>
          <a href="/privacy">Privacy</a>
        </div>
      </nav>

      <section className="hero-section" id="top">
        <div className="hero-copy">
          <p className="eyebrow">One powerful word every day</p>
          <h1>A sharper vocabulary, built quietly.</h1>
          <p className="hero-lede">
            Verbsy helps you learn precise, memorable words through daily
            reading, clean review, and calm Home Screen and Lock Screen widgets.
          </p>
          <div className="hero-actions">
            <AppStoreModalButton />
            <a className="secondary-link" href="#features">
              See how it works
            </a>
          </div>
        </div>

        <div className="phone-stage" aria-label="Verbsy app preview">
          <div className="phone-frame">
            <div className="phone-screen">
              <div className="phone-header">
                <span>Today</span>
                <span>3-day streak</span>
              </div>
              <div className="word-card">
                <p className="card-label">Word of the day</p>
                <h2>Poignant</h2>
                <p className="pronunciation">POYN-yunt · adjective</p>
                <p>
                  Deeply touching, often because something feels tender,
                  beautiful, or quietly painful.
                </p>
              </div>
              <div className="mini-row">
                <span>Review</span>
                <strong>92%</strong>
              </div>
              <div className="mini-row muted">
                <span>Saved words</span>
                <strong>18</strong>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="feature-band" id="features">
        <div className="section-heading">
          <p className="eyebrow">Built for recall</p>
          <h2>Small enough to keep. Useful enough to matter.</h2>
        </div>
        <div className="feature-grid">
          <article>
            <span className="feature-icon">01</span>
            <h3>Daily words with context</h3>
            <p>
              Learn the definition, pronunciation, example, and when the word
              actually fits.
            </p>
          </article>
          <article>
            <span className="feature-icon">02</span>
            <h3>Review that makes words stick</h3>
            <p>
              Quick recall prompts help turn words you recognize into words you
              can use.
            </p>
          </article>
          <article>
            <span className="feature-icon">03</span>
            <h3>A library worth browsing</h3>
            <p>
              Explore words across psychology, writing, communication,
              philosophy, productivity, and emotion.
            </p>
          </article>
        </div>
      </section>

      <section className="word-strip" aria-label="Sample words">
        {words.map((item) => (
          <article key={item.word}>
            <h3>{item.word}</h3>
            <p>{item.definition}</p>
          </article>
        ))}
      </section>

      <section className="widgets-section" id="widgets">
        <div className="section-heading">
          <p className="eyebrow">Home and Lock Screen widgets</p>
          <h2>Keep a better word where you will actually see it.</h2>
        </div>
        <div className="widget-showcase">
          <div className="widget-card paper">
            <span>Verbsy</span>
            <h3>Lucid</h3>
            <p>Clear and easy to understand.</p>
          </div>
          <div className="widget-card ink">
            <span>Today</span>
            <h3>Aplomb</h3>
            <p>Confident composure.</p>
          </div>
          <div className="lock-widget">
            <strong>Equanimity</strong>
            <span>Mental calm under stress.</span>
          </div>
        </div>
      </section>

      <section className="final-cta">
        <p className="eyebrow">Verbsy for iPhone</p>
        <h2>Make your vocabulary feel more precise every day.</h2>
        <AppStoreModalButton />
      </section>

      <footer className="site-footer">
        <span>Verbsy</span>
        <div>
          <a href="/terms">Terms</a>
          <a href="/privacy">Privacy</a>
        </div>
      </footer>
    </main>
  );
}
