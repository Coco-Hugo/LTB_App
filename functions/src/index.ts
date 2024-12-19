import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

type IncomingData = {
  uid?: string;
  displayName?: string;
  photoURL?: string;
  email?: string;
};

export const createCustomToken = functions.https.onCall(
  async (data: unknown) => {
    try {
      console.log("Raw function call data:", data);

      const incoming = (data as { data?: IncomingData })?.data;
      if (!incoming) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "No data field provided."
        );
      }

      const {uid, displayName, photoURL, email} = incoming;
      console.log("Extracted values:", {uid, displayName, photoURL, email});

      if (!uid) {
        console.error("No UID provided in data");
        throw new functions.https.HttpsError(
          "invalid-argument",
          "The function must be called with a valid uid."
        );
      }

      console.log("Creating custom token for uid:", uid);
      const token = await admin.auth().createCustomToken(uid);
      console.log("Custom token created successfully");

      try {
        console.log("Updating/creating user in Firebase Auth");
        await admin.auth().updateUser(uid, {
          displayName: displayName || undefined,
          photoURL: photoURL || undefined,
          email: email || undefined,
        });
        console.log("User updated successfully");
      } catch (error: any) {
        if (error.code === "auth/user-not-found") {
          console.log("User not found, creating new user");
          await admin.auth().createUser({
            uid,
            displayName: displayName || undefined,
            photoURL: photoURL || undefined,
            email: email || undefined,
          });
          console.log("New user created successfully");
        } else {
          console.error("Error updating/creating user:", error);
          throw error;
        }
      }

      return {token};
    } catch (error: any) {
      console.error(
        "Top level error:",
        error instanceof Error ? error.message : "Unknown error"
      );
      if (error instanceof Error) {
        throw new functions.https.HttpsError("internal", error.message);
      }
      throw new functions.https.HttpsError(
        "internal",
        "An unknown error occurred"
      );
    }
  }
);
