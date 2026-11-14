const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const {prepare} = require('./prepare-web-ci.cjs');
function values(){return {
  FIREBASE_WEB_ENV_JSON:JSON.stringify({FIREBASE_WEB_API_KEY:'test-only',FIREBASE_WEB_APP_ID:'test-only',FIREBASE_WEB_MESSAGING_SENDER_ID:'test-only',FIREBASE_WEB_PROJECT_ID:'eventhub-group4',FIREBASE_WEB_AUTH_DOMAIN:'eventhub-group4.firebaseapp.com',FIREBASE_RECAPTCHA_ENTERPRISE_SITE_KEY:'test-only'}),
  FIREBASE_SERVICE_ACCOUNT:JSON.stringify({type:'service_account',project_id:'eventhub-group4',client_email:'github-test@eventhub-group4.iam.gserviceaccount.com',private_key:'-----BEGIN PRIVATE KEY----- test fixture, never a real key'})
};}
test('missing/malformed config and wrong project never create a deploy file',()=>{
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'eventhub-ci-'));const target=path.join(dir,'env.json');
 try {
  assert.throws(()=>prepare({},target),/Missing GitHub Actions secret/);
  assert.throws(()=>prepare({...values(),FIREBASE_WEB_ENV_JSON:'{broken'},target),/Invalid JSON/);
  const config=JSON.parse(values().FIREBASE_WEB_ENV_JSON);config.FIREBASE_WEB_PROJECT_ID='other-project';
  assert.throws(()=>prepare({...values(),FIREBASE_WEB_ENV_JSON:JSON.stringify(config)},target),/Deploy project/);
  const account=JSON.parse(values().FIREBASE_SERVICE_ACCOUNT);account.private_key='';
  assert.throws(()=>prepare({...values(),FIREBASE_SERVICE_ACCOUNT:JSON.stringify(account)},target),/Invalid dedicated/);
  assert.equal(fs.existsSync(target),false);
 }finally{fs.rmSync(dir,{recursive:true,force:true});}
});
test('only web configuration is written; deployment credentials stay out of build file',()=>{
 const dir=fs.mkdtempSync(path.join(os.tmpdir(),'eventhub-ci-'));const target=path.join(dir,'env.json');
 try {prepare(values(),target);const contents=fs.readFileSync(target,'utf8');assert.equal(JSON.parse(contents).FIREBASE_WEB_PROJECT_ID,'eventhub-group4');assert.equal(contents.includes('PRIVATE KEY'),false);}
 finally{fs.rmSync(dir,{recursive:true,force:true});}
});
