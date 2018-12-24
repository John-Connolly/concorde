////
////  HTMLPages.swift
////  Dev
////
////  Created by John Connolly on 2018-11-11.
////
//
//import Foundation
//import concorde
import Html
//import Css

let stylesheet: StaticString = """
body {
padding-top: 40px;
padding-bottom: 40px;
background-color: #FFFFFF;
}

.login {
max-width: 330px;
padding: 15px;
margin: 0 auto;
}


.login .logo {
margin-bottom: 20px;
text-align: center;
}

.btn-primary {
background-color: #FFD62F;
border: none;
color: white;
}

.btn-primary:hover {
box-shadow: 0 6px 12px rgba(0,0,0,.2);
background-color: #FFD62F;
}

.login .form-control {
position: relative;
height: auto;
-webkit-box-sizing: border-box;
box-sizing: border-box;
padding: 10px;
font-size: 16px;
}
.login .form-control:focus {
z-index: 2;
}
.login input[type="email"] {
margin-bottom: -1px;
border-bottom-right-radius: 0;
border-bottom-left-radius: 0;
}
.login input[type="password"] {
margin-bottom: 10px;
border-top-left-radius: 0;
border-top-right-radius: 0;
}
"""


// Login

func headStyle(style styleString: StaticString) -> ChildOf<Tag.Html> {
    return head([
        title("Swift-Q"),
        boostrapCss(),
        boostrapJs(),
        style(styleString)
        ])
}

func loginPage() -> String {
    let node = html([
        headStyle(style: stylesheet),
          body([
                div([Attribute("class", "container")], [
                    form()
                    ]),
            ])

        ])

    return render(node)
}



//<div class="logo">
//<img src="/logo.png" width="64px">

func form() -> Node {
    let node = form([Attribute("action", "/login"),
                     Attribute("method", "post"),
                     Attribute("class", "login"),
                     Attribute("role", "form")], [
                        label(for: "email"),
                        bInput(name: "email", placeholder: "Email address"),
                        label(for: "password"),
                        bInput(name: "password", placeholder: "Password"),
                        button(with: "Sign In")
        ])
    return node
}

func image(name: String) -> Node {
    return img(src: name, alt: "", [
        //width="64px"
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
        Attribute("id", "name"),
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
