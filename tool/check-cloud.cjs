// Read-only cloud verification. No API keys, auth tokens or prompts are printed.
const fs = require('node:fs');
const path = require('node:path');
const base = path.join(__dirname, '../firebase/tests/node_modules/firebase-tools/lib/');
const project = 'eventhub-group4', number = '218815401893';
const apps = {web:'1:218815401893:web:1b87cb5223b55aee53a24c',android:'1:218815401893:android:c3166be3181a746c53a24c'};
(async()=>{
  await require(base+'requireAuth').requireAuth({project,...require(base+'auth').getGlobalDefaultAccount()});
  const api=require(base+'appcheck/api'), C=require(base+'apiv2').Client;
  const result={checkedAt:new Date().toISOString(),project,config:{},verificationWindowHours:24};
  for(const [kind,provider] of [['web','recaptcha-enterprise'],['android','play-integrity']]) {
    try {const config=await api.getProviderConfig(number,apps[kind],provider);
      result.config[kind]={registered:!!config.name,provider,ttl:config.tokenTtl};
    } catch (_) {result.config[kind]={registered:false,provider};}
  }
  result.androidDebugTokenCount=(await api.listDebugTokens(number,apps.android)).length;
  const services=await api.listServices(number);
  result.enforcement=Object.fromEntries(services.filter(s=>['firestore.googleapis.com','firebaseml.googleapis.com'].some(k=>s.name.endsWith('/'+k))).map(s=>[s.name.split('/').pop(),s.enforcementMode]));
  const rc=new C({urlPrefix:'https://firebaseremoteconfig.googleapis.com',apiVersion:'v1'});
  const r=await rc.get(`projects/${project}/remoteConfig`),p=r.body.parameters||{};
  result.ai={rcVersion:r.body.version?.versionNumber,enabled:p.ai_feature_enabled?.defaultValue?.value==='true',model:p.ai_model_name?.defaultValue?.value,promptConfigured:!!p.ai_prompt_template?.defaultValue?.value};
  const m=new C({urlPrefix:'https://monitoring.googleapis.com',apiVersion:'v3'});
  try {const r=await m.get(`projects/${project}/timeSeries`,{queryParams:{filter:'metric.type="firebaseappcheck.googleapis.com/services/verification_count"','interval.endTime':new Date().toISOString(),'interval.startTime':new Date(Date.now()-86400000).toISOString(),view:'FULL',pageSize:100}});
    result.appCheckObservations=(r.body.timeSeries||[]).map(s=>({service:s.resource.labels.service_id,appId:s.metric.labels.app_id,result:s.metric.labels.result,security:s.metric.labels.security,count:s.points.reduce((n,p)=>n+Number(p.value.int64Value||p.value.doubleValue||0),0)}));
  } catch (_) {result.appCheckObservations=null;result.metricsError='Unavailable; check Console manually';}
  result.hostingHttpStatus=(await fetch('https://eventhub-group4.web.app')).status;
  result.realGeminiOutputs='Not verified by this read-only script';
  result.nativeAndCrossRole='Require user execution and evidence';
  const out=path.join(__dirname,'../evidence/cloud-readiness/config-status.json');
  fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,JSON.stringify(result,null,2)+'\n');
  console.log(JSON.stringify(result,null,2));
})().catch(()=>{console.error('Cloud verification failed. Check Firebase CLI login, project permissions and network. No completion result recorded.');process.exitCode=1});
