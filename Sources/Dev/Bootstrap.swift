//
//  Bootstrap'.swift
//  Dev
//
//  Created by John Connolly on 2018-12-26.
//

import Foundation
import Html

func head(style file: String) -> ChildOf<Tag.Html> {
    return .head([
        .meta(attributes: [Attribute("charset", "utf-8")]),
        .meta(attributes: [
            Attribute("http-equiv", "X-UA-Compatible"),
            Attribute("content", "IE=edge")
            ]),
        .meta(attributes: [
            Attribute("name", "viewport"),
            Attribute("content", "width=device-width, initial-scale=1")
            ]),
        boostrapCss,
        boostrapJs,
        codeCss,
        codeJS,
        codeScript,
        .link(attributes: [Attribute("href", file), Attribute("rel", "stylesheet")]),
        .link(attributes: [Attribute("rel", "icon"), Attribute("href", "concorde.png")])
        ])
}

let jquery = Node.script(attributes: [
    .src("https://code.jquery.com/jquery-3.3.1.slim.min.js"),
    Attribute("integrity", "sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"),
    Attribute("crossorigin", "anonymous"),
    ])

let boostrapCss = ChildOf<Tag.Head>.link(attributes: [
    Attribute("rel", "stylesheet"),
    Attribute("href", "https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css"),
    Attribute("integrity", "sha384-9gVQ4dYFwwWSjIDZnLEWnxCjeSWFphJiwGPXr1jddIhOegiu1FwO5qRGvFXOdJZ4"),
    Attribute("crossorigin", "anonymous")
    ])


let boostrapJs = ChildOf<Tag.Head>.script(attributes: [
    .src("https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js"),
    Attribute("integrity", "sha384-uefMccjFJAIv6A+rW+L4AHf99KvxDjWSu1z9VI8SKNVmz4sk7buKt/6v9KI65qnm"),
    Attribute("crossorigin", "anonymous")
    ])


let codeCss = ChildOf<Tag.Head>.link(attributes: [
    Attribute("rel", "stylesheet"),
    Attribute("href", "github.css"),
])

let codeJS = ChildOf<Tag.Head>.script(attributes: [
     Attribute("src","/highlight.pack.js"),
])

let codeScript = ChildOf<Tag.Head>.script(unsafe: "hljs.initHighlightingOnLoad();")
