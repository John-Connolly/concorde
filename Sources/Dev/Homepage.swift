//
//  Homepage.swift
//  concorde
//
//  Created by John Connolly on 2019-03-11.
//

import Foundation
import concorde
import Html



func mainView() -> Middleware {
    return (authorize(true)
        >=> write(status: .ok)
        >=> write(body: renderContent(), contentType: .html))
}

private func renderContent() -> String {
    return render(mainContent())
}

func mainContent() -> Node {
    return html([
        head(style: "concorde.css", title2: "Concorde"),
        body([
            div([classAtr("container-fluid")], [
                div([classAtr("row justify-content-md-center")], [
                    div([classAtr("col-md-10")], [
                        img(src: "carbon.png", alt: "", [classAtr("img-fluid")])
                        ])
                    ]),
                div([classAtr("row justify-content-md-center")], [
                    div([classAtr("col-md-auto")], [
                        h1([.text("Concorde")]),
                        h2([.text("Functional Web Framework")]),
                        ]),
                    ])
                ]),
            div([classAtr("row justify-content-md-center")], [
                br,
                div([classAtr("col-md-auto")], [
                    button([classAtr("btn btn-dark")], [.text("Getting Started")]),
                    ]),
                div([classAtr("col-md-auto")], [
                    button([classAtr("btn btn-outline-dark")], [.text("Github")])
                    ]),
                ])
            ])
        ])
}
