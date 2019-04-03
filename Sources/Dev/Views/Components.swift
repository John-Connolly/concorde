////
////  Components.swift
////  Dev
////
////  Created by John Connolly on 2019-03-20.
////
//
//import Foundation
//import Html
//
//extension Node {
//    public static func div(attributes: [Attribute<Tag.Div>] = [], array: [Node]) -> Node {
//        return .element("div", attributes: attributes, .fragment(array))
//    }
//
//    public static func ul(attributes: [Attribute<Tag.Ul>] = [], _ content: [ChildOf<Tag.Ul>]) -> Node {
//        return .element("ul", attributes: attributes, ChildOf.fragment(content).rawValue)
//    }
//}
//
//func baseView(nodes: [Node]) -> Node {
//    return .html([
//        head(style: "concorde.css"),//, title2: "Concorde"
//        .body([
//            .div(attributes: [.class("container-fluid")], array: nodes)
//            ])
//        ])
//}
//
//let logo = View<(), [Node]> { title in
//    return [
//        .div(attributes: [.class("row justify-content-md-left")],
//            .div(attributes: [.class("col-md-1")],
//                  .a(attributes: [.href("/")],
//                     Node.img(src: "concorde.png", alt: "", attributes: [.id("logo-img")])
//                    )
//                )
//            )
//        ]
//}
//
//let sectionTitle = View<(String, String?), [Node]> { title in
//    return [
//        .br,
//        .br,
//        .br,
//        .div(attributes: [.class("row justify-content-md-center"), .id(title.1 ?? "")],
//            .div(attributes: [.class("col-md-auto")],
//                .h2(.text(title.0)),
//                .br
//                )
//            )
//    ]
//}
//
//let descriptionSection = View<String, [Node]> { content in
//    return [
//        .div(attributes: [.class("row justify-content-md-center")], [
//            .div(attributes: [.class("col-md-auto")], [
//                .br,
//                .h6([.text(content)]),
//                ]),
//            ]),
//        ]
//}
//
//let paragraphSection = View<String, [Node]> { content in
//    return [
//        .div(attributes: [.class("row justify-content-md-center")], [
//            .div(attributes: [.class("col-md-5")], [
//                .br,
//                .p(attributes: [.id("paragraph-p")],[.text(content)]),
//                ]),
//            ]),
//        ]
//}
//
//
//
//let codeSection = View<String, [Node]> { content in
//    return [
//        .div(attributes:[.class("row justify-content-md-center")], [
//            .div(attributes: [.class("col-md-auto")], [
//                .pre([.code(attributes: [.class("Swift")],[.text(
//                    content
//                    )])
//                    ])
//                ])
//            ])
//    ]
//}
//
//
//private let listItem = View<(String, String), [ChildOf<Tag.Ul>]> { content in
//    return [
//        .li(.a(attributes: [.href(content.0), .id("list-a")], .text(content.1)))
//    ]
//}
//
//let listSection = View<[(String, String)], [Node]> { content in
//    return [
//        .div(attributes: [.class("row justify-content-md-center")],
//            .div(attributes: [.class("col-md-auto justify-content-md-center")],
//                .ul(attributes: [.id("list-ul")], content.flatMap(listItem.view))
//                )
//        )
//    ]
//}
//
//let footerSection = View<(), [Node]> { _ in
//    return [
//        .footer(attributes: [.class("pt-4 my-md-5 pt-md-5 border-top")], [
//            .div(attributes: [.class("container")], [
//                .span(attributes: [.class("text-muted")], [.text("Concorde")])
//                ])
//            ])
//    ]
//}
