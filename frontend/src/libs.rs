#![allow(non_snake_case)]
use dioxus::prelude::*;

pub enum Align {
    center,
    start,
    end,
    around,
    evenly,
    between,
}

impl Align {
    pub fn getAlign(&self) -> String {
        match self {
            Align::start => "justify-start".to_string(),
            Align::center => "justify-center".to_string(),
            Align::end => "justify-end".to_string(),
            Align::around => "justify-around".to_string(),
            Align::evenly => "justify-evenly".to_string(),
            Align::between => "justify-between".to_string(),
        }
    }
}

#[derive(Props)]
pub struct ValueProps<'a> {
    value: &'a str,
    children: Element<'a>,
}


#[derive(Props)]
pub struct ChildrenProps<'a> {
    #[props(default = "")]
    pub class: &'a str,

    #[props(default = Align::start)]
    pub align: Align,

    pub children: Element<'a>,
}


pub fn Padding<'a>(cx: Scope<'a, ValueProps<'a>>) -> Element {
    cx.render(rsx! {
        div{
            padding: cx.props.value,
            &cx.props.children
        }
    })
}


pub fn Margin<'a>(cx: Scope<'a, ValueProps<'a>>) -> Element {
    cx.render(rsx! {
        div{
            margin: cx.props.value,
            &cx.props.children
        }
    })
}