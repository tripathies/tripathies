"use strict";
const test=require("node:test");
const assert=require("node:assert/strict");
const {spawn}=require("node:child_process");
const path=require("node:path");
test("local demo exposes health, catalogue and simulated checkout",async(t)=>{
 const port=31000+Math.floor(Math.random()*1000);
 const child=spawn(process.execPath,[path.join(__dirname,"..","server.js")],{env:{...process.env,PORT:String(port),LOCAL_DEMO_MODE:"true"},stdio:["ignore","pipe","pipe"]});
 t.after(()=>{if(!child.killed)child.kill("SIGTERM");});
 const base="http://127.0.0.1:"+port;
 let ready=false;
 for(let i=0;i<50;i++){try{const r=await fetch(base+"/healthz");if(r.ok){ready=true;break;}}catch{} await new Promise(resolve=>setTimeout(resolve,100));}
 assert.equal(ready,true,"server should start within five seconds");
 const health=await (await fetch(base+"/healthz")).json();
 assert.equal(health.mode,"local-demo");
 const catalogue=await (await fetch(base+"/api/products")).json();
 assert.equal(catalogue.products.length,4);
 const orderResponse=await fetch(base+"/api/orders",{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify({items:[{productId:"tee-001",size:"3Y",quantity:2}]})});
 assert.equal(orderResponse.status,201);
 const order=(await orderResponse.json()).order;
 assert.equal(order.status,"Demo accepted");
 assert.equal(order.total,798);
 const invalid=await fetch(base+"/api/orders",{method:"POST",headers:{"content-type":"application/json"},body:JSON.stringify({items:[{productId:"missing",size:"3Y",quantity:1}]})});
 assert.equal(invalid.status,400);
});