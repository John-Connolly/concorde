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

func jsonExample() -> Middleware {
    struct Car: Codable {
        let make: String
        let doors: Int
    }
    let car = Car(make: "Ford", doors: 4)
    return write(status: .ok) >=> write(body: car)
}

func mainContent() -> Node {
    return html([
        head(style: "concorde.css", title2: "Concorde"),
        body([
            div([classAtr("container-fluid")], [
                br,
                div([classAtr("row justify-content-md-end")],[
                    div([
                        a([Attribute("href", "/json")], [
                            .text("JSON")
                            ]),
                        a([Attribute("href", "/routing")], [
                            .text("Routing")
                            ])
                        ])
                    ]),
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
                    a([classAtr("btn btn-outline-dark"),
                       Attribute("href","https://github.com/John-Connolly/concorde"),
                       Attribute("role","button"),
                       ], [.text("Github")]),

                    ]),
                ]),
            br,
            br,
            br,

            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-auto")], [
                    h2([.text("Why?")]),
                    br
                    ]),
                ]),

            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-3")], [
                    h4([.text("Type Safety")]),
                    p([.text("Allows errors that would normally be caught at run time be caught at compile time. Concordes router uses applicative parsing techniques that eliminate a whole class of bugs")])
                    ]),
                div([classAtr("col-md-3")], [
                    h4([.text("Concurrent")]),
                    p([.text("Event driven non-blocking IO this means your app can handle a lot of concurrency using a small number of kernel threads.")])
                    ]),
                div([classAtr("col-md-3")], [
                    h4([.text("Composable")]),
                    p([.text("Concorde is built from the ground up using functions. This means integrating  with third party libraries is easy!")])
                    ]),
                ]),


            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-auto")], [
                    h2([.text("Getting Started")]),
                    br
                    ]),
                ]),


            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-auto")], [
                    h4([.text("Installation")]),
                    br
                    ]),
                ]),


            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-auto")], [
                    pre([ code([classAtr("Swift")],[.text(
                        """
                        .package(url: "https://github.com/John-Connolly/concorde.git", from: "1.0.0")
                        """
                        )])
                        ])
                    ])
                ]),

            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-auto")], [
                    br,
                    h4([.text("HELLO WORLD")]),
                    br
                    ]),
                ]),


            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-auto")], [
                    pre([ code([classAtr("Swift")],[.text(
                        """
                        /// Model your app as a sum type
                        enum Routes: Sitemap {
                            case home

                            func action() -> Middleware {
                                switch self {
                                case .root:
                                    return write(status: .ok) >=> write(body: "HELLO WORLD")
                                }
                            }
                        }
                        """
                        )])
                        ])
                    ])
                ]),

            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-auto")], [
                    br,
                    h6([.text("Set up and run Concorde on localhost:8080")]),
                    br
                    ]),
                ]),

            div([classAtr("row justify-content-md-center")], [
                div([classAtr("col-md-auto")], [
                    pre([ code([classAtr("Swift")],[.text(
                        """
                        let sitemap: [Route<SiteRoutes>] = [
                            pure(unzurry(Routes.home)) <*> (path("home") *> end)
                        ]

                        let flightPlan = router(register: sitemap, middleware: [fileMiddleware], notFound: notFoundPage())
                        let wings = Configuration(port: 8080, resources: preflightCheck)
                        let plane = concorde(flightPlan, config: wings)
                        plane.apply(wings)

                        """
                        )])
                        ])
                    ])
                ]),

            footer([classAtr("pt-4 my-md-5 pt-md-5 border-top")], [
                div([classAtr("container")], [
                    span([classAtr("text-muted")], [.text("Concorde")])
                    ])
                ])
            ])
        ])
}
