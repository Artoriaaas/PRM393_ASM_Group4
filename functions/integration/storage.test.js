const { test, before, after } = require("node:test");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");
const { ref, uploadBytes, getBytes } = require("firebase/storage");
let env;
before(async () => {
  if (!process.env.FIREBASE_STORAGE_EMULATOR_HOST)
    throw new Error("Run with Storage emulator");
  env = await initializeTestEnvironment({
    projectId: "demo-eventhub",
    storage: { rules: readFileSync(join(__dirname, "../../firebase/storage.rules"), "utf8") },
  });
});
after(async () => {
  await env?.cleanup();
});
test("Storage permits owner PDF and rejects other UID, anonymous and wrong MIME", async () => {
  const owner = env
    .authenticatedContext("owner", { email_verified: true })
    .storage();
  const other = env
    .authenticatedContext("other", { email_verified: true })
    .storage();
  const bytes = new Uint8Array([37, 80, 68, 70]);
  await assertSucceeds(
    uploadBytes(ref(owner, "reports/owner/test.pdf"), bytes, {
      contentType: "application/pdf",
    }),
  );
  await assertFails(
    uploadBytes(ref(owner, "reports/other/test.pdf"), bytes, {
      contentType: "application/pdf",
    }),
  );
  await assertFails(
    uploadBytes(ref(owner, "reports/owner/wrong.pdf"), bytes, {
      contentType: "text/plain",
    }),
  );
  await assertFails(getBytes(ref(other, "reports/owner/test.pdf")));
  await assertFails(
    getBytes(
      ref(env.unauthenticatedContext().storage(), "reports/owner/test.pdf"),
    ),
  );
});
