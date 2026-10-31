import {DefaultAzureCredential} from "@azure/identity";
import {CosmosClient} from "@azure/cosmos";
const endpoint=process.env.COSMOS_ENDPOINT;
const databaseName=process.env.COSMOS_DATABASE||"littlenest";
const containerName=process.env.COSMOS_PRODUCTS_CONTAINER||"products";
if(!endpoint)throw new Error("Set COSMOS_ENDPOINT to the private Cosmos DB endpoint.");
const client=new CosmosClient({endpoint,aadCredentials:new DefaultAzureCredential()});
const container=client.database(databaseName).container(containerName);
const products=[
 {id:"tee-001",name:"Rainbow Day T-shirt",category:"Tops",size:["2Y","3Y","4Y","5Y"],colour:"Sky blue",price:399,image:"🌈",description:"Soft everyday cotton tee."},
 {id:"dress-002",name:"Little Garden Dress",category:"Dresses",size:["2Y","3Y","4Y","5Y"],colour:"Mint",price:799,image:"🌼",description:"A light dress for sunny days."},
 {id:"hoodie-003",name:"Cloud Club Hoodie",category:"Outerwear",size:["3Y","4Y","5Y","6Y"],colour:"Lavender",price:999,image:"☁️",description:"A cosy layer for cooler evenings."},
 {id:"shorts-004",name:"Playtime Shorts",category:"Bottoms",size:["2Y","3Y","4Y","5Y"],colour:"Coral",price:449,image:"🧡",description:"Easy-fit shorts for busy little days."}
];
for(const product of products){await container.items.upsert(product);console.log("Seeded "+product.id);}
console.log("Seed complete.");