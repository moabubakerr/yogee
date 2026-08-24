# Things to ask

Questions for the client, in plain language. Nothing here needs a technical
answer — every one of them is a business or preference decision.

*(Our own working notes and the technical detail behind each item are in
`docs/publish-checklist.md`. This file is for the conversation.)*

---

## Decisions that can never be changed later

These three are locked in permanently the day the app goes live. Getting them
right now is free. Changing them afterwards means rebuilding the app from
scratch, or in some cases is simply impossible.

**1. Where in the world should the app's data live?**

The app's database sits in one physical location, chosen once. Everyone using
the app talks to that location, so the further away they are, the slower every
screen feels.

Right now it is in London, which was a test setup, not a decision.

- Where will most users be? (UK, Europe, Asia, US…)
- This is the single most permanent choice on the list. Once the database is
  created, the location cannot be moved — not by us, not by Google, not by
  paying more. The only fix would be building a new one and copying everything
  across.

**2. What web address does the business own?**

Every app has a hidden internal name, and by convention it is based on a domain
name — something like `com.yogeeapp.yogee`.

Ours currently says `com.mycompany.yoogeeapp` — "mycompany" is a placeholder the
app-building tool inserted, and nobody replaced it.

- Do you own a domain name for Yogee? If not, is one being registered?
- Once the app is published, this name is permanent on both Apple and Google.
  It is visible in some places. Shipping "mycompany" means the app is
  permanently labelled with a placeholder.

**3. Who should own the accounts — you or us?**

The app needs several accounts: Google (for the app's data), Google Play, Apple,
and possibly Facebook.

Our strong recommendation is that **every one of these is registered in your
name, with us added as helpers.** The reverse — us owning them and handing over
later — is messy and in some cases not possible at all.

- Are you happy to be the account holder on all of them?
- Some require a company registration number and can take a week or two to
  verify, so it is worth starting early.

---

## Accounts we need from you

**4. Google Play — we have never had access to this**

This is the account that publishes the Android app. We have never seen it, and
nothing about the Android release can be finished without it.

- Can you invite us in?
- Was it registered as a **personal** account or a **company** account? A company
  account needs an official business registration number and takes time to
  verify. A personal account shows an individual's name publicly as the
  publisher, and changing that later is a slow support process.
- Is there a backup of the app's "signing key"? Think of it as the app's
  signature — Google can only accept updates that carry the same one. If it is
  lost and Google is not holding a copy, the app can never be updated again, and
  the only way forward is publishing a brand new app and asking every user to
  reinstall. Worth confirming Google holds a copy.

**5. Apple**

We have access here, but a few things need confirming.

- The iPhone version of notifications has **never once been tested**. Testing it
  needs a real iPhone and a Mac computer — it cannot be done on this machine or
  on any simulator. Is there an iPhone we can test on, and someone with a Mac?
- Apple charges an annual developer fee. Is that active and paid?

**6. Facebook login**

The app has "Sign in with Facebook" buttons, but they cannot work — the setup on
Facebook's side was never done.

- Does a Facebook developer account for Yogee already exist, and who owns it?
- Do you actually want Facebook login? It is not free to add: Facebook requires
  a published privacy policy and a review process before it works for the
  public. If it is not important, removing the buttons is quicker and cleaner
  than finishing it.

---

## Notifications

**7. What should the two unused notification switches actually do?**

The settings screen shows three switches. One of them works — **"Social
notifications"**, a single on/off covering everything another person does to
you:

- when someone likes your post or comment
- when someone replies to your post
- when someone follows you

These are deliberately one switch rather than three. They are the same request
from a user's point of view — "tell me when someone interacts with me" — and a
screen full of near-identical options mostly persuades people to switch
everything off. If you would rather people could turn likes off but keep
replies, say so and we will split it.

Two more switches exist but do nothing at all, because nobody has ever decided
what they mean:

- **"New releases and announcements"**
- **"App updates"**

For "New releases and announcements", these are two very different things and we
need to know which you meant:

- *New content* — "a new meditation track just landed". This is easy, automatic,
  and cheap: it can send itself whenever something is added to the library.
- *News from the business* — "we're running a promotion this week". This needs a
  real person to write each message and press send, which means someone has to
  build a page for them to do that, and someone has to be responsible for
  writing them.

For **"App updates"** — what did you have in mind? Apple and Google already tell
users when an update is available, so this may be repeating something they
already get. If the idea was "here's what changed in this version", that is
probably better shown inside the app than sent as a notification.

Also worth deciding: right now these two are switched **off** for everyone by
default, so even after we build them, nobody would receive anything until they
went and turned them on themselves.

**If neither has a clear answer yet, our recommendation is to remove both
switches for now** and add them back when there is something real to send.
Leaving switches on screen that do nothing makes people distrust the rest of the
settings.

**8. Should notifications be on or off by default?**

"Social notifications" is currently **on** by default — people get them unless
they turn it off. This is what most social apps do, and users still get asked
for permission by the phone itself the first time.

- Happy with that, or would you rather people opt in?
- Anything else worth notifying people about? The most obvious gap is **direct
  messages** — the app has private chat, but it sends no notification at all
  right now, so people simply will not know they have a message.

---

## Money

**9. Is there anything to pay for?**

The app currently has a subscription screen, but it only offers "Continue on
free plan" — there is no paid option behind it, and no payment system connected.

- Is there meant to be a paid tier at launch? If so, what does paying unlock?
- One thing worth knowing early: for anything bought *inside* an app, Apple and
  Google require their own payment systems and take a percentage (commonly
  15–30%). Outside payment providers are not permitted for this. So the pricing
  needs to account for their cut.
- If there is no paid tier at launch, we would rather strip the unused payment
  machinery out — it makes the app bigger and adds things for Apple and Google
  to review, for no benefit.

---

## Legal and safety

**10. Who is writing the privacy policy?**

Both app stores refuse to publish without one, and it has to be live on a real
web address. Facebook requires one too.

It must honestly describe what the app collects. Currently that includes: email
address, name, profile photo, bio, location, **private journal entries**,
**private messages**, and the device the person uses.

- Do you have a lawyer or a template service for this?
- Both stores also make *you* fill in a questionnaire declaring exactly what is
  collected and why. We can draft it, but you have to confirm it is accurate —
  getting it wrong can get the app pulled.
- Is there a terms of service? The app has user-written content, so it is
  normally expected.

**11. What happens when someone posts something abusive?**

This one is a genuine gap and it will block Apple approval.

The app has public posts, comments, and private messages between users. Right
now there is:

- no way for a user to report a post
- no way for a user to block another user
- no way for anyone — including you — to delete something once it is posted

That last one is not an exaggeration. Content is currently permanent by design.

Apple specifically rejects apps with user-written content unless there is a
report button, a block feature, and someone actually reading the reports.

- Who will handle reports when they come in, and how quickly?
- We will need to build the report and block features. Worth knowing now so it
  is in the plan rather than discovered at rejection.

---

## Launch

**12. What are we launching, where, and when?**

- **Android, iPhone, or both?** There is also a web version in the codebase,
  but it needs extra work before images display properly.
- **Which countries?**
- **Is there a target date?** Two deadlines exist regardless of what we choose:
  one piece of Google's platform stops accepting updates after **30 October
  2026**, and Google periodically requires apps to be rebuilt against newer
  standards. Neither is difficult, but neither should collide with launch week.
- **Roughly how many users at launch?** This decides whether the app's current
  image sizes are an urgent problem or just a slightly expensive one. Some of
  the artwork files are enormous — one is 12.6 MB for a thumbnail displayed
  smaller than a postage stamp.

**13. Does anything in the current test app need keeping?**

There is a test version of the app with data in it. When the real one is created
it starts empty.

- Is any of the existing content — tracks, albums, artwork, test accounts —
  worth carrying across, or does the real version start clean?
- Is there a real content library ready to load in, and who is providing it?

---

## After launch

**14. Who runs it once it is live?**

- Who publishes updates after we finish? If it is us, that should be an agreed
  arrangement rather than an assumption.
- Who should receive the crash reports and the app store review notifications?
  These go to a real inbox and someone needs to be reading them.
- If we stop working together, does everything continue to work without us? The
  answer should be yes, and that mostly depends on question 3.
