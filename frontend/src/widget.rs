#![allow(non_snake_case)]
use dioxus::prelude::*;

use crate::libs::*;


pub fn 卡片() {}

pub fn 行<'a>(cx: Scope<'a, ChildrenProps<'a>>) -> Element {
    cx.render(rsx! {
        div{
            class: "flex {cx.props.class} {cx.props.align.getAlign()}",
            &cx.props.children
        }
    })
}

pub fn 列<'a>(cx: Scope<'a, ChildrenProps<'a>>) -> Element {
    cx.render(rsx! {
        div{
            class: "flex flex-col {cx.props.class} {cx.props.align.getAlign()}",
            &cx.props.children
        }
    })
}

pub fn 居中<'a>(cx: Scope<'a, ChildrenProps<'a>>) -> Element {
    cx.render(rsx!(
        div {
            text_align: "center",
            &cx.props.children
    }))
}