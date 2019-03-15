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
                ]),
            br,
            br,
            br,

            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-auto")], [
                    h2([.text("Why?")]),
                    ]),
                ]),

            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-3")], [
                    h4([.text("Type Safety")]),
                    p([.text("Allows errors that would normally be caught at run time be caught at compile time.  Concordes router uses applicative parsing techniques that eliminate a whole class of bugs")])
                    ]),
                div([classAtr("col-md-3")], [
                    h4([.text("Concurrent")]),
                    p([.text("Event driven non-blocking IO this means your app can handle a lot of concurrency using a small number of kernel threads.")])
                    ]),
                div([classAtr("col-md-3")], [
                    h4([.text("Stateless")]),
                    p([.text("Stuff goes here!!")])
                    ]),
                ])
            ])
        ])
}
