#![allow(non_snake_case)]
use dioxus::prelude::*;

pub enum Align {
    Center,
    Start,
    End,
    Around,
    Evenly,
    Between,
}

impl Align {
    pub fn getAlign(&self) -> String {
        match self {
            Align::Start => "justify-start".to_string(),
            Align::Center => "justify-center".to_string(),
            Align::End => "justify-end".to_string(),
            Align::Around => "justify-around".to_string(),
            Align::Evenly => "justify-evenly".to_string(),
            Align::Between => "justify-between".to_string(),
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

    #[props(default = Align::Start)]
    pub align: Align,

    pub children: Element<'a>,
}


pub fn Padding<'a>(cx: Scope<'a, ValueProps<'a>>) -> Element {
    render! {
        div{
            padding: cx.props.value,
            &cx.props.children
        }
    }
}


pub fn Margin<'a>(cx: Scope<'a, ValueProps<'a>>) -> Element {
    render! {
        div{
            margin: cx.props.value,
            &cx.props.children
        }
    }
}