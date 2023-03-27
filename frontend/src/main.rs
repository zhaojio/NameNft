#![allow(non_snake_case)]
mod libs;
mod widget;

use dioxus::prelude::*;
use libs::*;
use widget::*;

fn main() {
    dioxus_web::launch(app);
}

pub fn app(cx: Scope) -> Element {
    cx.render(rsx!(
        头部导航{}
        列{
            class:"pt-10",
            p{
                class :"text-3xl text-white",
                "The Name Servers of the next internet evolution."
            }
            p{
                text_align: "center",
                width:"50%",
                class:"text-gray-400 pt-3",
                "Minting the username into NFT, make the username on supported chains unique, turn it into a digital asset, and can be used between multiple chains."
                a{
                    class:"text-blue-300",
                    href:"#",
                    " Learn More >"
                }
            }

        }
    ))
}

fn 头部导航(cx: Scope) -> Element {
    cx.render(rsx! {
        行 {
            class: "pl-32 px-5 py-3 bg-gray-800",
            align: Align::between,
            行{
                a{
                    class:"text-2xl",
                    href:"#",
                    "NAME-NFT"
                }
               
                a{
                    class:"pl-5",
                    href:"#",
                    "How it Work"
                }

                a{
                    class:"pl-5",
                    href:"#",
                    "Development"
                }
            }
            button{
                class:"mr-10 px-5 py-3 bg-blue-900 text-white text-xs rounded-md font-bold",
                onclick: move |e|{
                    dbg!(e);
                },
                "CONNECT WALLET"
            }
    }
    })
}

fn 页尾(cx: Scope) -> Element {
    cx.render(rsx! {
        div{
            bottom:"0px",
            position:"absolute",
            "页面结尾"
        }
    })
}
