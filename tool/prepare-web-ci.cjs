// Validate secrets without logging their values. Never writes the service account.
const fs = require('node:fs');
const path = require('node:path');
function prepare(env = process.env, output = path.join(__dirname, '../web/web_env.json')) {
  const parse = (key) => {
    if (!env[key]) throw new Error(`Missing GitHub Actions secret: ${key}`);
    try { return JSON.parse(env[key]); } catch { throw new Error(`Invalid JSON in secret: ${key}`); }
  };
  const config = parse('FIREBASE_WEB_ENV_JSON');
  const account = parse('FIREBASE_SERVICE_ACCOUNT');
  for (const key of ['FIREBASE_WEB_API_KEY','FIREBASE_WEB_APP_ID','FIREBASE_WEB_MESSAGING_SENDER_ID','FIREBASE_WEB_PROJECT_ID','FIREBASE_WEB_AUTH_DOMAIN','FIREBASE_RECAPTCHA_ENTERPRISE_SITE_KEY']) {
    if (typeof config[key] !== 'string' || !config[key].trim()) throw new Error(`Missing Web configuration field: ${key}`);
  }
  if (config.FIREBASE_WEB_PROJECT_ID !== 'eventhub-group4' || account.project_id !== 'eventhub-group4') throw new Error('Deploy project must be eventhub-group4.');
  if (account.type !== 'service_account' || typeof account.client_email !== 'string' || !account.client_email.endsWith('@eventhub-group4.iam.gserviceaccount.com') || typeof account.private_key !== 'string' || !account.private_key.includes('BEGIN PRIVATE KEY')) throw new Error('Invalid dedicated Firebase deployment service account.');
  fs.writeFileSync(output, JSON.stringify(config), { mode: 0o600 });
}
if (require.main === module) {
  try { prepare(); console.log('Web build configuration validated.'); }
  catch (error) { console.error(error.message); process.exitCode = 1; }
}
module.exports = { prepare };
