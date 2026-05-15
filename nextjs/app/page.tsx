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
          <p className="eyebrow">Vocabulary for people who choose their words carefully</p>
          <h1>Learn one word a day that you will actually use.</h1>
          <p className="hero-lede">
            Verbsy teaches precise, memorable words with short daily lessons,
            gentle review, and minimal widgets for your Home Screen and Lock
            Screen.
          </p>
          <div className="hero-actions">
            <AppStoreModalButton />
            <a className="secondary-link" href="#features">
              Preview the app
            </a>
          </div>
          <p className="launch-note">iPhone only. App Store launch coming soon.</p>
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
          <p className="eyebrow">Built for real recall</p>
          <h2>A daily vocabulary habit that feels light, not academic.</h2>
        </div>
        <div className="feature-grid">
          <article>
            <span className="feature-icon">01</span>
            <h3>Understand the word in seconds</h3>
            <p>
              See the meaning, pronunciation, example, tone, and the kind of
              moment where the word belongs.
            </p>
          </article>
          <article>
            <span className="feature-icon">02</span>
            <h3>Move from recognition to usage</h3>
            <p>
              Quick review prompts help you remember what a word means and
              when you would naturally say it.
            </p>
          </article>
          <article>
            <span className="feature-icon">03</span>
            <h3>Browse words by how they feel</h3>
            <p>
              Explore vocabulary for psychology, writing, communication,
              philosophy, productivity, emotion, and self-improvement.
            </p>
          </article>
        </div>
      </section>

      <section className="proof-band" aria-label="Why Verbsy">
        <div>
          <p className="eyebrow">Why it works</p>
          <h2>Most vocabulary apps teach too much at once. Verbsy keeps the habit small.</h2>
        </div>
        <p>
          One word. A clear example. A fast review. A quiet reminder where you
          already look every day. That is enough to make better words familiar
          without turning vocabulary into another task.
        </p>
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
          <h2>Put today&apos;s word where your day already starts.</h2>
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
        <h2>Build a vocabulary that makes your thoughts easier to say.</h2>
        <p>
          Daily words, focused review, and calm widgets in one clean iOS app.
        </p>
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
