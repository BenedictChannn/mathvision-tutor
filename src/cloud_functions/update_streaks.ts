// Cloud Function: Nightly streak aggregation
// -----------------------------------------------------------------------------
// Calculates each user's consecutive solve streak (days with at least one solve
// per calendar day) and stores it under /users/{uid}.streak.
// Trigger: runs every night at 02:00 UTC.
// -----------------------------------------------------------------------------
import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// Helper: returns string YYYY-MM-DD in UTC for given timestamp
const toDateKey = (ts: admin.firestore.Timestamp) =>
  ts.toDate().toISOString().substring(0, 10);

export const updateStreaks = functions.pubsub
  .schedule("0 2 * * *") // 02:00 UTC daily
  .timeZone("Etc/UTC")
  .onRun(async () => {
    const solveSnap = await db.collection("solve_records").get();

    // Map<uid, Set<yyyy-mm-dd>>
    const userDays: Record<string, Set<string>> = {};
    solveSnap.forEach((doc) => {
      const data = doc.data();
      const uid = data.uid as string | undefined;
      const ts = (data.created_at as admin.firestore.Timestamp) ?? null;
      if (!uid || !ts) return;
      const day = toDateKey(ts);
      if (!userDays[uid]) userDays[uid] = new Set();
      userDays[uid].add(day);
    });

    const todayKey = new Date().toISOString().substring(0, 10);

    const batch = db.batch();
    Object.entries(userDays).forEach(([uid, days]) => {
      // Calculate consecutive streak ending yesterday (today's solves not yet counted)
      let streak = 0;
      let cursor = new Date();
      cursor.setUTCHours(0, 0, 0, 0); // today 00:00
      for (;;) {
        const key = cursor.toISOString().substring(0, 10);
        if (key === todayKey) {
          cursor.setUTCDate(cursor.getUTCDate() - 1);
          continue; // skip today; full days only
        }
        if (days.has(key)) {
          streak += 1;
          cursor.setUTCDate(cursor.getUTCDate() - 1);
        } else {
          break;
        }
      }

      const userRef = db.collection("users").doc(uid);
      batch.set(
        userRef,
        {
          streak,
          streak_updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    });

    await batch.commit();
    console.log(`Updated streaks for ${Object.keys(userDays).length} users`);
  });
