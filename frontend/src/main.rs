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
        列{
            class:"w-full",
            头部导航{}
            中间文字{}
            列{
                class:"lg:w-1/2 w-10/12 pt-7",
                搜索框{}
                销售列表{}
            }
        }
    ))
}

fn 中间文字(cx: Scope) -> Element {
    render!{
        列{
            class:"pt-10 w-1/2",
            p{
                text_align: "center",
                class :"text-3xl text-white",
                "The Name Servers of the next internet evolution."
            }
            p{
                text_align: "center",
                class:"text-gray-400 pt-3",
                "Minting the username into NFT, make the username on supported chains unique, turn it into a digital asset, and can be used between multiple chains."
                a{
                    class:"text-blue-400",
                    href:"#",
                    " Learn More >"
                }
            }
        }
    }
}

fn 头部导航(cx: Scope) -> Element {
    cx.render(rsx! {
        行 {
            class: "pl-32 px-5 py-3 bg-gray-800 w-full",
            align: Align::between,
            行{
                a{
                    class:"text-2xl",
                    href:"#",
                    "NAME-NFT"
                }      
                a{
                    style:"text-underline-offset: 6px;text-decoration-thickness: 2px;text-decoration-color:#3b82f6",
                    class:"pl-5 hover:underline",
                    href:"#",
                    "How it Work"
                }
                a{
                    style:"text-underline-offset: 6px;text-decoration-thickness: 2px;text-decoration-color:#3b82f6",
                    class:"pl-5 hover:underline",
                    href:"#",
                    "Development"
                }
                a{
                    style:"text-underline-offset: 6px;text-decoration-thickness: 2px;text-decoration-color:#3b82f6",
                    class:"pl-5 hover:underline",
                    href:"#",
                    "About"
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

fn 搜索框(cx: Scope) -> Element {
    cx.render(rsx! {
        居中{
            class:"w-full",        
            div{
                class:"relative mb-6 w-full",
                div{
                    class:"absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none",
                    svg{
                        class:"w-5 h-5 text-blue-500",
                        fill:"currentColor",
                        view_box:"0 0 50 50",
                        path{
                            d:"M 21 3 C 11.601563 3 4 10.601563 4 20 C 4 29.398438 11.601563 37 21 37 C 24.355469 37 27.460938 36.015625 30.09375 34.34375 L 42.375 46.625 L 46.625 42.375 L 34.5 30.28125 C 36.679688 27.421875 38 23.878906 38 20 C 38 10.601563 30.398438 3 21 3 Z M 21 7 C 28.199219 7 34 12.800781 34 20 C 34 27.199219 28.199219 33 21 33 C 13.800781 33 8 27.199219 8 20 C 8 12.800781 13.800781 7 21 7 Z"
                        }
                    }
                }
                
                //响应回车事件 输入之后添加删除icon
                input{
                    class:"
                    w-full
                    focus:outline-none 
                    text-md rounded-lg block pl-10 p-3 
                    focus:ring-1 focus:ring-inset focus:ring-blue-600 
                    bg-gray-700 border-gray-600 placeholder-gray-400 focus:text-white",
                    placeholder:"Input a username"
                }
                
                button{
                    class:"absolute top-0 right-0 bottom-0 m-px px-4
                    text-sm font-medium rounded-r-lg hover:bg-blue-800 
                    focus:outline-none bg-blue-900 hover:bg-blue-700 ",     
                    svg{
                        class:"h-5 w-5 text-gray-300",
                        fill:"currentColor",
                        view_box:"0 0 50 50",
                        path{
                            d:"M 21 3 C 11.601563 3 4 10.601563 4 20 C 4 29.398438 11.601563 37 21 37 C 24.355469 37 27.460938 36.015625 30.09375 34.34375 L 42.375 46.625 L 46.625 42.375 L 34.5 30.28125 C 36.679688 27.421875 38 23.878906 38 20 C 38 10.601563 30.398438 3 21 3 Z M 21 7 C 28.199219 7 34 12.800781 34 20 C 34 27.199219 28.199219 33 21 33 C 13.800781 33 8 27.199219 8 20 C 8 12.800781 13.800781 7 21 7 Z"
                        }
                    }
                }
            }
        }
    })
}

fn 销售列表(cx: Scope) -> Element {
    render!{
        行{
            class:"w-full",
            align:Align::between,
            div{
                class:"pl-2 text-lg text-gray-300",
                "Search Results"
            }
            div{
                class:"text-lg text-gray-300",
                "Price hiht to low"
            }
        }
        列{
            class:"w-full m-3",
            //列表头部
            列表头部{}
            for _ in 0..100{
                列表项{}
            }
        }
    }
}

fn 列表头部(cx: Scope) -> Element {
    render!{
        行{
            class:"w-full px-3 py-2 bg-gray-700 rounded-tl-lg rounded-tr-lg ",
            p{
                class:"w-1/4 text-gray-300 text-sm",
                "Username"
            }
            p{
                class:"w-1/3 text-gray-300 text-sm",
                "Price"
            }
            p{
                class:"w-1/4 text-gray-300 text-sm",
                "Level"
            }
            p{
                class:"w-1/4 text-gray-300 text-sm",
                "On The Chain"
            }
        }
    }
}

fn 列表项(cx: Scope) -> Element {
    render!{
       a{
        class:"w-full",
        href:"#",
        行{
            class:"w-full px-3 py-2 
            mb-px 
            bg-gray-800 hover:bg-gray-700",
            p{
                class:"pl-1 w-1/4 text-md text-white",
                "com"
            },
            p{
                class:"w-1/3 text-sm text-white",
                "10.23424eth"
                p{
                    class:"text-xs text-gray-400",
                    "30000$"
                }
            },
            p{
                class:"w-1/4 text-sm text-white",
                "Top"
            }
            p{
                class:"w-1/4 text-sm text-white",
                "Moonbeam"
            }
        }
       }
        //分割线
    }
}

fn 搜索结果(cx: Scope) -> Element {
    render! {
        行{
            class:"w-full",
            align:Align::between,
            div{
                class:"text-lg",
                "Search Results"
            }
            div{
                class:"text-lg",
                "Search Results"
            }
        }
       
    }
}