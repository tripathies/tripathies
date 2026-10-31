"use strict";
const {app}=require("@azure/functions");
const {DefaultAzureCredential}=require("@azure/identity");
const {CosmosClient}=require("@azure/cosmos");
let ordersContainer;
function getOrdersContainer(){
 if(!ordersContainer){
  if(!process.env.COSMOS_ENDPOINT||!process.env.COSMOS_DATABASE)throw new Error("COSMOS_ENDPOINT and COSMOS_DATABASE must be configured.");
  const client=new CosmosClient({endpoint:process.env.COSMOS_ENDPOINT,aadCredentials:new DefaultAzureCredential()});
  ordersContainer=client.database(process.env.COSMOS_DATABASE).container(process.env.COSMOS_ORDERS_CONTAINER||"orders");
 }
 return ordersContainer;
}
app.storageQueue("process-littlenest-order",{
 queueName:"orders",
 connection:"OrdersQueue",
 handler:async(message,context)=>{
  const raw=typeof message==="string"?message:message?.toString?.();
  const payload=JSON.parse(raw||"{}");
  if(!payload.orderId)throw new Error("Queue message does not contain orderId.");
  const container=getOrdersContainer();
  const {resource:order}=await container.item(payload.orderId,payload.orderId).read();
  if(!order)throw new Error("Order not found: "+payload.orderId);
  order.status="Processed";
  order.processedAt=new Date().toISOString();
  await container.items.upsert(order);
  context.log("Processed LittleNest demo order "+payload.orderId);
 }
});