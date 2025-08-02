// Cloud Function: Stripe checkout + webhook to top-up user credits
// -----------------------------------------------------------------------------
// Prerequisites:
//   • Set environment variable STRIPE_SECRET_KEY (Stripe secret key)
//   • Set STRIPE_WEBHOOK_SECRET (signing secret for webhook endpoint)
//   • Deploy with:  firebase deploy --only functions:topUpCredits,functions:stripeWebhook
// -----------------------------------------------------------------------------
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";

admin.initializeApp();
const db = admin.firestore();

const stripeSecret = process.env.STRIPE_SECRET_KEY;
if (!stripeSecret) {
  throw new Error("STRIPE_SECRET_KEY env var is missing");
}
const stripe = new Stripe(stripeSecret);

// Price ID configured in Stripe Dashboard (e.g., 100 credits for $4.99)
const PRICE_ID = "price_123456789"; // TODO: replace with real price id

// -----------------------------------------------------------------------------
// HTTPS Callable Function – creates a Checkout Session
// -----------------------------------------------------------------------------
export const topUpCredits = functions.https.onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to purchase credits."
    );
  }

  try {
    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      payment_method_types: ["card"],
      line_items: [
        {
          price: PRICE_ID,
          quantity: 1,
        },
      ],
      metadata: { uid },
      success_url: "https://example.com/success", // TODO replace
      cancel_url: "https://example.com/cancel", // TODO replace
    });

    return { sessionId: session.id, url: session.url };
  } catch (err: any) {
    console.error("Stripe session error", err);
    throw new functions.https.HttpsError("internal", err.message);
  }
});

// -----------------------------------------------------------------------------
// Webhook – listens for checkout.session.completed and increments credits
// -----------------------------------------------------------------------------
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers["stripe-signature"] as string;
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!webhookSecret) {
    console.error("Webhook secret missing");
    res.status(500).send("config error");
    return;
  }

  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err: any) {
    console.error("Webhook signature verification failed", err.message);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  if (event.type === "checkout.session.completed") {
    const session = event.data.object as Stripe.Checkout.Session;
    const uid = (session.metadata?.uid as string) || null;
    if (uid) {
      const creditsToAdd = 10; // For now, each purchase gives 10 credits
      await db
        .collection("users")
        .doc(uid)
        .set(
          {
            credits_left: admin.firestore.FieldValue.increment(creditsToAdd),
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      console.log(`Added ${creditsToAdd} credits to ${uid}`);
    }
  }

  res.status(200).json({ received: true });
  return;
});
