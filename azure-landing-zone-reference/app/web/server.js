"use strict";
const http=require("node:http"),path=require("node:path"),fs=require("node:fs"),{randomUUID}=require("node:crypto");
const PORT=Number(process.env.PORT||3000),LOCAL_DEMO_MODE=process.env.LOCAL_DEMO_MODE==="true",MAX_BODY_BYTES=32768;
const productsSeed=[
{id:"tee-001",name:"Rainbow Day T-shirt",category:"Tops",size:["2Y","3Y","4Y","5Y"],colour:"Sky blue",price:399,image:"🌈",description:"Soft everyday cotton tee."},
{id:"dress-002",name:"Little Garden Dress",category:"Dresses",size:["2Y","3Y","4Y","5Y"],colour:"Mint",price:799,image:"🌼",description:"A light dress for sunny days."},
{id:"hoodie-003",name:"Cloud Club Hoodie",category:"Outerwear",size:["3Y","4Y","5Y","6Y"],colour:"Lavender",price:999,image:"☁️",description:"A cosy layer for cooler evenings."},
{id:"shorts-004",name:"Playtime Shorts",category:"Bottoms",size:["2Y","3Y","4Y","5Y"],colour:"Coral",price:449,image:"🧡",description:"Easy-fit shorts for busy little days."}
];
let cosmos,productsContainer,ordersContainer,queueClient,secretClient;
async function getAzureClients(){
 if(LOCAL_DEMO_MODE)return null;
 if(!process.env.COSMOS_ENDPOINT||!process.env.COSMOS_DATABASE)throw new Error("COSMOS_ENDPOINT and COSMOS_DATABASE must be configured.");
 if(!cosmos){
  const {CosmosClient}=require("@azure/cosmos"),{DefaultAzureCredential}=require("@azure/identity");
  const credential=new DefaultAzureCredential();
  cosmos=new CosmosClient({endpoint:process.env.COSMOS_ENDPOINT,aadCredentials:credential});
  const db=cosmos.database(process.env.COSMOS_DATABASE);
  productsContainer=db.container(process.env.COSMOS_PRODUCTS_CONTAINER||"products");
  ordersContainer=db.container(process.env.COSMOS_ORDERS_CONTAINER||"orders");
  const {QueueClient}=require("@azure/storage-queue");
  if(!process.env.STORAGE_ACCOUNT_NAME||!process.env.ORDERS_QUEUE_NAME)throw new Error("STORAGE_ACCOUNT_NAME and ORDERS_QUEUE_NAME must be configured.");
  queueClient=new QueueClient("https://"+process.env.STORAGE_ACCOUNT_NAME+".queue.core.windows.net/"+process.env.ORDERS_QUEUE_NAME,credential);
 }
 return {productsContainer,ordersContainer,queueClient};
}
async function listProducts(){
 if(LOCAL_DEMO_MODE)return productsSeed;
 const c=await getAzureClients(),r=await c.productsContainer.items.query("SELECT * FROM c").fetchAll();
 return r.resources;
}
async function getOptionalBanner(){
 if(!process.env.KEY_VAULT_URL||!process.env.DEMO_BANNER_SECRET_NAME)return null;
 const {DefaultAzureCredential}=require("@azure/identity");
 const {SecretClient}=require("@azure/keyvault-secrets");
 if(!secretClient)secretClient=new SecretClient(process.env.KEY_VAULT_URL,new DefaultAzureCredential());
 const result=await secretClient.getSecret(process.env.DEMO_BANNER_SECRET_NAME);
 return result.value||null;
}
async function createOrder(input){
 const allowed=new Map(productsSeed.map(p=>[p.id,p]));
 if(!Array.isArray(input.items)||input.items.length<1||input.items.length>10)throw new Error("Choose between one and ten products.");
 const items=input.items.map(item=>{
  const p=allowed.get(String(item.productId)),q=Number(item.quantity),s=String(item.size||"");
  if(!p||!Number.isInteger(q)||q<1||q>5||!p.size.includes(s))throw new Error("A product, size or quantity is invalid.");
  return {productId:p.id,name:p.name,size:s,quantity:q,unitPrice:p.price,lineTotal:p.price*q};
 });
 const order={id:randomUUID(),status:"Received",createdAt:new Date().toISOString(),items,total:items.reduce((sum,i)=>sum+i.lineTotal,0),demo:true};
 if(LOCAL_DEMO_MODE){order.status="Demo accepted";return order;}
 const c=await getAzureClients();
 await c.ordersContainer.items.create(order);
 await c.queueClient.sendMessage(JSON.stringify({orderId:order.id,createdAt:order.createdAt}));
 return order;
}
function sendJson(res,status,value){res.writeHead(status,{"content-type":"application/json; charset=utf-8","cache-control":"no-store","x-content-type-options":"nosniff"});res.end(JSON.stringify(value));}
function readJson(req){return new Promise((resolve,reject)=>{let body="";req.on("data",chunk=>{body+=chunk;if(Buffer.byteLength(body)>MAX_BODY_BYTES){reject(new Error("Request body is too large."));req.destroy();}});req.on("end",()=>{try{resolve(body?JSON.parse(body):{});}catch{reject(new Error("Request must contain valid JSON."));}});req.on("error",reject);});}
const server=http.createServer(async(req,res)=>{
 try{
  const url=new URL(req.url,"http://localhost");
  if(req.method==="GET"&&url.pathname==="/healthz")return sendJson(res,200,{status:"ok",mode:LOCAL_DEMO_MODE?"local-demo":"azure"});
  if(req.method==="GET"&&url.pathname==="/api/products")return sendJson(res,200,{products:await listProducts()});
  if(req.method==="GET"&&url.pathname==="/api/banner")return sendJson(res,200,{banner:LOCAL_DEMO_MODE?null:await getOptionalBanner()});
  if(req.method==="POST"&&url.pathname==="/api/orders")return sendJson(res,201,{order:await createOrder(await readJson(req))});
  if(req.method==="GET"&&url.pathname==="/"){
   const file=path.join(__dirname,"public","index.html");
   res.writeHead(200,{"content-type":"text/html; charset=utf-8","content-security-policy":"default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'","x-content-type-options":"nosniff","referrer-policy":"no-referrer"});
   return res.end(fs.readFileSync(file));
  }
  return sendJson(res,404,{error:"Not found."});
 }catch(error){
  const status=/invalid|choose|request body/i.test(error.message)?400:500;
  console.error(error);
  return sendJson(res,status,{error:status===400?error.message:"The request could not be completed."});
 }
});
server.listen(PORT,"0.0.0.0",()=>console.log("LittleNest listening on "+PORT+"; mode="+(LOCAL_DEMO_MODE?"local-demo":"azure")));
