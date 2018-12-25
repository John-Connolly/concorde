//
//  Login.swift
//  concorde
//
//  Created by John Connolly on 2018-12-25.
//

import Foundation
import Html

func head(style file: String) -> ChildOf<Tag.Html> {
    return head([
        title("Swift-Q"),
        boostrapCss(),
        boostrapJs(),
        link([Attribute("href", file), Attribute("rel", "stylesheet")])
        ])
}

func loginPage() -> String {
    let node = html([
        head(style: "login.css"),
        body([
            div([Attribute("class", "container")], [
                form()
                ]),
            ])

        ])

    return render(node)
}

func form() -> Node {
    let node = form([Attribute("action", "/login"),
                     Attribute("method", "post"),
                     Attribute("class", "login"),
                     Attribute("role", "form")], [
                        div([Attribute("class", "logo")], [
                               image(name: "logo.png"),
                            ]),
                        label(for: "email"),
                        bInput(name: "email", placeholder: "Email address"),
                        label(for: "password"),
                        bInput(name: "password", placeholder: "Password"),
                        br,
                        button(with: "Sign In")
        ])
    return node
}

func image(name: String) -> Node {
    return img(src: name, alt: "", [
        Attribute("width", "64px")
        ])
}

func label(for name: String) -> Node {
    return label([
        Attribute("for", name),
        Attribute("class", "sr-only"),], [
            .raw("Email address")
        ]
    )
}

func button(with name: String) -> Node {
    return button([
        Attribute("class", "btn btn-lg btn-primary btn-block"),
        Attribute("type", "submit"),
        ], [
            .raw(name)
        ])
}

func bInput(name: String, placeholder: String) -> Node {
    return input([
        Attribute("name", name),
        Attribute("class", "form-control"),
        Attribute("id", name),
        Attribute("placeholder", placeholder)
        ])
}

func boostrapCss() -> ChildOf<Tag.Head> {
    return link([
        Attribute("rel", "stylesheet"),
        Attribute("href", "https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css"),
        Attribute("integrity", "sha384-9gVQ4dYFwwWSjIDZnLEWnxCjeSWFphJiwGPXr1jddIhOegiu1FwO5qRGvFXOdJZ4"),
        Attribute("crossorigin", "anonymous")
        ])
}

func boostrapJs() -> ChildOf<Tag.Head> {
    return script([
        Attribute("src","https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js"),
        Attribute("integrity", "sha384-uefMccjFJAIv6A+rW+L4AHf99KvxDjWSu1z9VI8SKNVmz4sk7buKt/6v9KI65qnm"),
        Attribute("crossorigin", "anonymous")
        ])
}
