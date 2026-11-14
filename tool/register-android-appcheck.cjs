// Register only the debug secret emitted by the running EventHub process on a test device.
// Does not open, close or operate the app; never prints/persists the secret.
const path=require('node:path'),fs=require('node:fs'),{execFileSync}=require('node:child_process');
const base=path.join(__dirname,'../firebase/tests/node_modules/firebase-tools/lib/');
(async()=>{
 const serial=process.argv[2];if(!serial || !/^[a-zA-Z0-9._:-]+$/.test(serial))throw Error('Usage: node tool/register-android-appcheck.cjs emulator-5554');
 const adb=process.env.ANDROID_HOME ? path.join(process.env.ANDROID_HOME,'platform-tools/adb.exe') : path.join(process.env.LOCALAPPDATA,'Android/Sdk/platform-tools/adb.exe');
 if(!fs.existsSync(adb))throw Error('Android platform-tools not found');
 const run=(args)=>execFileSync(adb,['-s',serial,...args],{encoding:'utf8',timeout:10000,stdio:['ignore','pipe','pipe']});
 const pid=run(['shell','pidof','com.eventhub.app']).trim();if(!/^\d+$/.test(pid))throw Error('Open EventHub debug app on this device first');
 const log=run(['logcat','-d','--pid='+pid,'-s','DebugAppCheckProvider']);
 const matches=[...log.matchAll(/debug secret[^\r\n]*?([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})/gi)];
 if(!matches.length)throw Error('No current EventHub debug secret found. Restart your debug app normally and retry; do not paste logcat into chat.');
 const token=matches.at(-1)[1];
 await require(base+'requireAuth').requireAuth({project:'eventhub-group4',...require(base+'auth').getGlobalDefaultAccount()});
 const api=require(base+'appcheck/api'),number='218815401893',app='1:218815401893:android:c3166be3181a746c53a24c';
 const existing=await api.listDebugTokens(number,app);
 if(existing.some(t=>t.token===token)){console.log('This EventHub Android debug device is already registered.');return;}
 await api.createDebugToken(number,app,'EventHub dedicated Android test device',token);
 console.log('Registered EventHub Android debug device. Secret was not printed or saved. Restart the app normally, use it, then run node tool/check-cloud.cjs to verify requests.');
})().catch(e=>{
 const safe=['Usage:','Android platform-tools','Open EventHub','No current EventHub'];
 console.error(safe.some(prefix=>e.message.startsWith(prefix)) ? e.message :
   'Cannot register the EventHub test device. Check connection, Firebase CLI login and project permissions. Token is not printed.');
 process.exitCode=1;
});
