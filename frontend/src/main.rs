#![allow(non_snake_case)]
use dioxus::prelude::*;

mod widget;
mod libs;

use widget::*;
use libs::*;


fn main() {
    dioxus_web::launch(app);
}

pub fn app(cx: Scope) -> Element {
    cx.render(rsx!(
        居中{
            头部导航{}
            Padding{
                value: "20px",
                Margin{value:"120px"}
                列{
                    p{
                        "The Name Servers of the next internet evolution."
                    }
                }
            
            }
        }
    ))
}

fn 头部导航(cx: Scope) -> Element {
    cx.render(rsx! {
        行 {
            align: Align::end,
            h1{"Development"}
            Padding{value:"10px"}
            div{"Document"}
        }
    })
}

fn 页面结尾(cx: Scope) -> Element {
    cx.render(rsx! {
        div{"页面结尾"}
    })
}

