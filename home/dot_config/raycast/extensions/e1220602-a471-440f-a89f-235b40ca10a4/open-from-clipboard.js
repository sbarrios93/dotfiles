var l=Object.defineProperty;var c=Object.getOwnPropertyDescriptor;var i=Object.getOwnPropertyNames;var p=Object.prototype.hasOwnProperty;var s=o=>l(o,"__esModule",{value:!0});var d=(o,a)=>{for(var n in a)l(o,n,{get:a[n],enumerable:!0})},f=(o,a,n,t)=>{if(a&&typeof a=="object"||typeof a=="function")for(let r of i(a))!p.call(o,r)&&(n||r!=="default")&&l(o,r,{get:()=>a[r],enumerable:!(t=c(a,r))||t.enumerable});return o};var m=(o=>(a,n)=>o&&o.get(a)||(n=f(s({}),a,1),o&&o.set(a,n),n))(typeof WeakMap!="undefined"?new WeakMap:0);var w={};d(w,{default:()=>u});var e=require("@raycast/api"),u=async()=>{(0,e.open)("cleanshot://open-from-clipboard"),await(0,e.closeMainWindow)()};module.exports=m(w);0&&(module.exports={});
