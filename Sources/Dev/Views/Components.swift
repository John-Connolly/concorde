//
//  Components.swift
//  Dev
//
//  Created by John Connolly on 2019-03-20.
//

import Foundation
import Html

func baseView(nodes: [Node]) -> Node {
    return html([
        head(style: "concorde.css", title2: "Concorde"),
        body([
            div([classAtr("container-fluid")],
                nodes
            )
            ])
        ])
}

let logo = View<(), [Node]> { title in
    return [
        div([classAtr("row justify-content-md-left")], [
            div([classAtr("col-md-1")], [
                a([Attribute("href","/home")], [
                    img(src: "concorde.png", alt: "", [classAtr("img-fluid"), Attribute("id", "logo-img")])
                    ]),
                ]),
            ]),
        ]
}

let sectionTitle = View<(String, String?), [Node]> { title in
    return [
        br,
        br,
        br,
        div([classAtr("row justify-content-md-center"), Attribute("id", title.1 ?? "")], [
            div([classAtr("col-md-auto")], [
                h2([.text(title.0)]),
                br
                ]),
            ])
    ]
}

let descriptionSection = View<String, [Node]> { content in
    return [
        div([classAtr("row justify-content-md-center")], [
            div([classAtr("col-md-auto")], [
                br,
                h6([.text(content)]),
                ]),
            ]),
        ]
}

let paragraphSection = View<String, [Node]> { content in
    return [
        div([classAtr("row justify-content-md-center")], [
            div([classAtr("col-md-5")], [
                br,
                p([Attribute("id","paragraph-p")],[.text(content)]),
                ]),
            ]),
        ]
}



let codeSection = View<String, [Node]> { content in
    return [
        div([classAtr("row justify-content-md-center")], [
            div([classAtr("col-md-auto")], [
                pre([code([classAtr("Swift")],[.text(
                    content
                    )])
                    ])
                ])
            ])
    ]
}


let footerSection = View<(), [Node]> { _ in
    return [
        footer([classAtr("pt-4 my-md-5 pt-md-5 border-top")], [
            div([classAtr("container")], [
                span([classAtr("text-muted")], [.text("Concorde")])
                ])
            ])
    ]
}
