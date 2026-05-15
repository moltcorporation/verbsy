# Onboarding Flows Agent Guide

This guide explains how to design a high-converting mobile app onboarding flow using the Cal AI onboarding pattern as the reference model. Cal AI's flow works because it does not treat onboarding as a form. It treats onboarding as a guided commitment journey: show the promise, collect useful personal context, reinforce why the app can help, reveal a personalized plan, then ask for signup/payment after the user has invested effort and seen value.

Use this guide for self-improvement apps, workout logs, habit trackers, horoscope apps, vocabulary apps, journaling apps, finance apps, wellness apps, and other consumer mobile products.

## Core Principle

The onboarding flow should make the user feel three things before the paywall:

- "This app understands my situation."
- "This plan was made for me."
- "I would lose something useful if I quit now."

Every screen should either increase personalization, increase belief, reduce friction, or prepare the user for the next commitment.

## Recommended Flow Structure

### 1. Start With a Concrete Product Promise

Open with a simple benefit-led welcome screen. Show the app's core mechanic visually, not just with copy.

Cal AI pattern:

- Large product mockup showing the core feature in action.
- Short headline: "Calorie tracking made easy."
- Primary CTA: "Get Started."
- Secondary existing-user path: "Already have an account? Sign In."
- Optional language selector in the corner.

For other apps:

- Vocabulary app: show a daily word card, quiz, and streak preview.
- Workout app: show a completed workout log and progress chart.
- Habit tracker: show a clean habit dashboard with streaks.
- Horoscope app: show a personalized reading preview.

Do not open with a marketing page. Open with the product outcome.

### 2. Use One Question Per Screen

Most onboarding screens should ask exactly one question. The question should be large, clear, and written in natural language.

Use this screen formula:

- Back button.
- Thin progress bar.
- Large question headline.
- Optional one-line explanation.
- Large tappable answer tiles.
- Sticky bottom CTA that becomes active after selection.

Good question examples:

- "What is your goal?"
- "What's stopping you from reaching your goals?"
- "How often do you work out?"
- "What would you like to accomplish?"
- "Have you tried other apps like this?"

Avoid dense forms early. If numeric or date input is required, use native-feeling pickers or sliders and explain why the data matters.

### 3. Explain Why Sensitive Inputs Matter

When asking for personal data, add a short purpose line. Cal AI repeatedly uses variants of:

- "This helps personalize your experience."
- "This will be used to calibrate your custom plan."
- "This helps us generate a plan for your calorie intake."

Use this pattern whenever asking for age, body data, skill level, mood, goals, constraints, current habits, budget, or schedule.

The explanation should be practical, not defensive. Never over-explain privacy on the question screen unless the user is explicitly granting a permission.

### 4. Collect Context Before Goals

Cal AI collects basic context before asking for the primary goal. This makes the later recommendation feel calculated rather than generic.

Useful context categories:

- Identity or profile: sex, age, height, weight, experience level, current level.
- Current behavior: workouts per week, current habits, current tools used.
- Acquisition source: where the user heard about the app.
- Constraints: schedule, lack of support, consistency issues, dietary limits, injuries, preferences.
- Goal: lose, maintain, gain, improve, learn, save, focus, feel better.
- Motivation: why the goal matters emotionally.

For non-health apps, adapt the categories:

- Vocabulary app: current confidence level, reading/writing goals, topics of interest, daily time available, biggest communication struggle.
- Habit app: habits to build, time of day, past failures, motivation, accountability preference.
- Horoscope app: birth info, relationship status, areas of life to focus on, notification preference.

### 5. Use Answer Tiles That Feel Effortless

Cal AI uses large rounded answer rows with icons, short labels, and sometimes one-line descriptions. This reduces cognitive load and makes the user feel progress is easy.

Use:

- 2 to 5 options per screen.
- Icons inside light circular containers.
- Short, mutually exclusive labels.
- Plain-language descriptions only when helpful.
- Disabled CTA until a choice is made, unless the tile tap advances automatically.

Avoid:

- Tiny radio buttons.
- Long paragraphs inside options.
- Many options with no grouping.
- Asking users to type unless typing is truly necessary.

### 6. Insert Value Interstitials Between Question Blocks

Do not run 20 question screens in a row. Cal AI breaks the flow with belief-building screens that show what the app will do with the user's answers.

Interstitial patterns to reuse:

- "Designed to help you stay on track" with a before/after chart.
- "Thank you for trusting us" with "Personalized to your goals."
- Feature preview cards showing how the app solves a problem.
- "All done! Time to generate your custom plan."

These screens should feel like a reward for progress, not an ad. They should also make the next set of questions feel justified.

### 7. Ask About Objections Explicitly

High-converting onboarding flows ask what has stopped the user before. This lets the app later position itself as the solution.

Cal AI asks:

- "What's stopping you from reaching your goals?"
- Options include consistency, habits, support, schedule, inspiration.

For other apps:

- Vocabulary app: "What makes it hard to improve your vocabulary?" Options: forgetting words, not knowing what to study, feeling awkward using new words, no daily routine.
- Workout app: "What usually stops you from staying consistent?" Options: time, motivation, not knowing what to do, soreness, travel.
- Habit app: "Why have habits fallen off before?" Options: too many goals, no reminders, perfectionism, lack of progress.

Later, mirror the selected objection in the plan, benefit bullets, or paywall.

### 8. Preview Optional Power Features as Choices

Cal AI asks about feature preferences after the user is invested:

- Add calories burned back to your daily goal?
- Rollover extra calories to the next day?

These are not basic profile questions. They are feature previews disguised as personalization. They teach the user that the app has flexible, advanced controls.

Use this for any app:

- "Do you want reminders that adapt when you miss a day?"
- "Should your plan get easier on busy days?"
- "Do you want AI suggestions based on your history?"
- "Should we include weekly review insights?"

Use a simple Yes/No layout and a visual example of the feature.

### 9. Place Social Proof After Investment

Cal AI shows social proof after the user has answered many questions, not at the start:

- "Join over 10 million people like you."
- 4.8 average rating.
- 250K+ or 300K+ app ratings.
- User avatars.
- Review cards.

This timing matters. Social proof is stronger once the user is deciding whether to trust the plan they helped create.

Use credible proof:

- Ratings.
- Total users.
- Testimonials.
- Expert sources.
- Community size.
- App Store review snippets.

Avoid unsupported claims. If real metrics are not available, use softer proof like user testimonials, expert methodology, or product transparency.

### 10. Prime Permissions Before Native Prompts

Do not trigger system permissions cold. Cal AI uses a pre-permission screen for notifications:

- "Stay on track with Cal AI notifications."
- Shows a fake native prompt with the "Allow" side emphasized.
- Uses a pointing hand cue.

Use this pattern:

- Explain the benefit in user terms.
- Show what permission is about to appear.
- Ask only when the user understands why it helps.

Permission examples:

- Notifications: reminders, streak protection, daily reading, habit check-ins.
- Camera: scan food, capture workouts, save journal moments, identify objects.
- Health data: import steps, workouts, sleep, nutrition.
- Location: local weather, local events, astrology location, outdoor routes.

Never ask for permissions that are not needed for the core experience.

### 11. Make "Generating Your Plan" Feel Real

After data collection, Cal AI uses a progress screen:

- Big percentage.
- "We're setting everything up for you."
- Progress bar.
- Specific items being generated: calories, carbs, protein, fats, health score.

This converts questionnaire effort into perceived value. The user feels the app is doing work on their behalf.

For any app, list the plan outputs:

- Vocabulary app: daily word level, topic mix, review schedule, quiz difficulty, streak plan.
- Workout app: training split, weekly volume, recovery plan, progression targets.
- Habit app: habit schedule, reminder timing, fallback plan, weekly review.
- Horoscope app: birth chart profile, daily reading style, relationship focus, notification timing.

Do not use a fake loader with vague copy. Name the exact outputs.

### 12. Reveal a Personalized Result Before the Paywall

Before asking for payment, show a summary that proves the user's answers mattered.

Cal AI shows:

- The selected goal.
- Daily recommendation.
- Editable targets.
- Macros.
- User info based on inputs.
- "You can edit this anytime."

For other apps, show:

- The user's goal.
- A personalized recommendation.
- The first few plan components.
- Input summary.
- Edit affordances.
- A CTA like "Let's get started!"

This screen should make the user think, "This is my plan." It should not be locked entirely behind the paywall.

### 13. Use a Plan Explanation Screen

Cal AI includes a scrollable proof/education section:

- "How to reach your goals."
- Steps the user should follow.
- "Why Cal AI?" comparison.
- Trusted by millions.
- Sources or methodology.

This screen builds rational justification before the purchase ask.

Use:

- A simple "how it works" checklist.
- A before/after comparison.
- Proof that the plan is based on inputs.
- Sources, if applicable.
- A sticky CTA at the bottom.

Keep it concrete. Do not make this a generic feature list.

### 14. Ask Users to Save Progress Before the Paywall

Cal AI asks users to create an account after the plan reveal and before the trial paywall:

- "Save your progress."
- Sign in with Apple.
- Sign in with Google.
- Continue with email.

This is a strong ordering:

1. User answers questions.
2. User sees personalized output.
3. User saves progress.
4. User reaches payment.

Avoid asking for account creation before the user understands the value unless the product technically requires it.

### 15. Design the Paywall as a Continuation, Not a Surprise

Cal AI's paywall is tightly connected to the onboarding flow:

- "Start your 3-day FREE trial to continue."
- Timeline: Today unlock features, in 2 days reminder, in 3 days billing starts.
- Explicit "No Payment Due Now."
- Plan cards with yearly preselected.
- Primary CTA: "Start My 3-Day Free Trial."
- Legal and restore links below.

High-converting paywall requirements:

- State the trial length in the headline and CTA.
- Make billing timing clear.
- Show when the user will be charged.
- Include cancellation reassurance.
- Preselect the best-value plan, usually yearly.
- Keep monthly available for comparison.
- Use a strong CTA, not "Continue."
- Keep terms, privacy, and restore visible.

### 16. Use a Downsell or One-Time Offer After Exit Intent

Cal AI shows a one-time offer after the user exits the main paywall:

- "Your one-time offer."
- Large discount visual.
- Struck-through old price.
- Lower annual price.
- Scarcity copy: "Once you close your one-time offer, it's gone."
- CTA: "Start Free Trial."
- Reassurance: "No Commitment - Cancel Anytime."

Use downsells carefully. They can lift revenue but can also teach users to close the first paywall. Reserve them for high-intent users who dismiss the initial offer.

## Screen Ordering Template

Use this default sequence for most consumer apps:

1. Product promise welcome screen.
2. Basic profile question.
3. Current behavior question.
4. Age or experience-level question.
5. Acquisition source question.
6. Previous solution question.
7. Value interstitial showing how the app helps.
8. Relevant personal data or preferences.
9. Current support/tooling question.
10. Main goal question.
11. Biggest obstacle question.
12. Preference or constraint question.
13. Emotional motivation question.
14. Trust/personalization interstitial.
15. Feature preference question.
16. Social proof and review screen.
17. Pre-permission screen.
18. Optional referral or invite code screen.
19. "All done" plan generation intro.
20. Plan generation progress screen.
21. Personalized plan reveal.
22. How-to-succeed / why-this-app screen.
23. Save progress / account creation.
24. Trial paywall.
25. Exit-intent downsell.

Not every app needs every screen. The target is usually 12 to 20 screens before the paywall for a consumer subscription app. Use fewer screens for utility apps with obvious value; use more screens for health, wellness, productivity, education, and self-improvement apps where personalization increases perceived value.

## Copywriting Rules

Use direct, high-intent language:

- "What is your goal?"
- "What would you like to accomplish?"
- "What's stopping you?"
- "Time to generate your custom plan."
- "Your daily recommendation."
- "Save your progress."

Avoid:

- "Tell us a little about yourself."
- "Help us improve your experience."
- "Complete your profile."
- "Almost there" repeated across many screens.
- Generic feature claims without a personal connection.

Subcopy should answer "why are you asking me this?" in one sentence.

## Visual Design Rules

Cal AI's flow is visually restrained and conversion-focused:

- White background.
- Oversized black headlines.
- Light gray answer cards.
- Minimal icon system.
- Rounded controls.
- Sticky bottom CTA.
- Clear progress bar.
- Sparse use of color for emphasis.
- Product visuals and charts where they make value tangible.

For future apps, adapt the visual style to the brand, but keep the same hierarchy:

- Question first.
- Answer choices second.
- CTA always reachable.
- No decorative clutter.
- No dense paragraphs.
- No competing navigation.

## Personalization Rules

Only ask questions that can influence one of these:

- The plan.
- The user's first session.
- Messaging on the paywall.
- Reminder timing.
- Feature defaults.
- Content recommendations.
- Difficulty level.
- Progress targets.

If an answer does not change anything, remove the question or move it to analytics after activation.

## Paywall Preparation Rules

Before the paywall, the user should have seen:

- Their selected goal.
- A personalized output.
- At least one reason the app is easier than alternatives.
- At least one trust signal.
- A clear explanation of what they unlock.

The paywall should feel like the next step to use the plan, not a sudden blocker.

## Agent Checklist

When designing an onboarding flow, verify:

- The first screen shows the app outcome, not a generic welcome.
- Each question has one clear job.
- Sensitive questions explain why they matter.
- Progress is visible throughout.
- Most inputs are taps, sliders, or pickers instead of typing.
- Interstitials break up the questionnaire and increase belief.
- The flow asks about obstacles and motivations.
- Feature previews are woven into personalization.
- Social proof appears before the final commitment.
- Permissions are primed before native prompts.
- A generated plan screen makes the user's answers feel valuable.
- Account creation happens after value is shown.
- The paywall includes trial timing, cancellation reassurance, plan comparison, restore, terms, and privacy.
- Any downsell is clearly optional and appears only after paywall dismissal.

## Common Mistakes

- Asking for signup before showing value.
- Asking too many questions with no explanation.
- Using the same "personalize your experience" subcopy on every screen without specificity.
- Treating onboarding as a survey instead of a value-building sequence.
- Showing a paywall before the user sees a personalized result.
- Triggering notification or camera prompts without priming.
- Hiding cancellation or billing details on the paywall.
- Making the UI feel like a settings form instead of a guided journey.

## Adaptation Example: Verbsy

For a vocabulary or communication app like Verbsy, adapt the Cal AI pattern like this:

1. Show a beautiful daily word card and a one-tap quiz preview.
2. Ask what the user wants: sound smarter, write better, understand emotions, speak more clearly, learn rare words.
3. Ask current level and daily reading habit.
4. Ask where they struggle: forgetting words, not using new words, weak writing, awkward conversations.
5. Ask preferred topics: psychology, philosophy, productivity, emotions, writing, relationships.
6. Insert an interstitial showing "Designed to make powerful words stick."
7. Ask reminder preference and daily time available.
8. Show social proof or credibility around daily learning.
9. Generate a personalized word plan: difficulty, topic mix, review schedule, daily notification time.
10. Reveal the first personalized daily word and learning plan.
11. Ask the user to save progress.
12. Present the paywall as unlocking the full daily plan, review system, quizzes, streaks, and advanced word collections.

The structure should feel like Cal AI, but the emotional promise should fit Verbsy: become more articulate, more emotionally precise, and more memorable in how you communicate.
