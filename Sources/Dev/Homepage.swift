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
    return render(homePage.map(baseView >>> pure).view(()))
}

func jsonExample() -> Middleware {
    struct Car: Codable {
        let make: String
        let doors: Int
    }
    let car = Car(make: "Ford", doors: 4)
    return write(status: .ok) >=> write(body: car)
}

enum Code {
    static let package = """
                         .package(url: "https://github.com/John-Connolly/concorde.git", from: "1.0.0")
                         """

    static let app =  """
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

    static let run =  """
                        let sitemap: [Route<SiteRoutes>] = [
                            pure(unzurry(Routes.home)) <*> (path("home") *> end)
                        ]

                        let flightPlan = router(register: sitemap, middleware: [fileMiddleware], notFound: notFoundPage())
                        let wings = Configuration(port: 8080, resources: preflightCheck)
                        let plane = concorde(flightPlan, config: wings)
                        plane.apply(wings)

                        """
}

private let homePage: View<(), [Node]> = (headerButtons
        <> imageView.contramap { _ in "carbon.png" }
        <> mainTitle
        <> mainButtons
        <> sectionTitle.contramap { _ in ("Why?", nil)}
        <> pointsSection
        <> sectionTitle.contramap { _ in ("Getting Started", "getting-started")}
        <> descriptionSection.contramap { _ in "Installation" }
        <> codeSection.contramap { _ in Code.package }
        <> descriptionSection.contramap { _ in "HELLO WORLD" }
        <> codeSection.contramap { _ in Code.app }
        <> descriptionSection.contramap { _ in "Set up and run Concorde on localhost:8080" }
        <> codeSection.contramap { _ in Code.run }
        <> footerSection.contramap { _ in }
    )

private func baseView(nodes: [Node]) -> Node {
    return html([
        head(style: "concorde.css", title2: "Concorde"),
        body([
            div([classAtr("container-fluid")],
                    nodes
                )
            ])
      ])
}

private let headerButtons = View<(), [Node]> { content in
    return [
        br,
        div([classAtr("row justify-content-md-end")],[
            div([
                a([Attribute("href", "/json")], [
                    .text("JSON")
                    ]),
                a([Attribute("href", "/routing")], [
                    .text("Routing")
                    ]),

                a([Attribute("href", "/eg")], [
                    .text("Examples")
                    ])
                ])
            ])
        ]
}

private let imageView = View<String, [Node]> { name in
    return [
        div([classAtr("row justify-content-md-center")], [
            div([classAtr("col-md-10")], [
                img(src: name, alt: "", [classAtr("img-fluid")])
                ])
            ]),
    ]
}

private let mainTitle = View<(), [Node]> { content in
    return [
        div([classAtr("row justify-content-md-center")], [
            div([classAtr("col-md-auto")], [
                h1([.text("Concorde")]),
                h2([.text("Functional Web Framework")]),
                ]),
            ])
    ]
}

private let mainButtons = View<(), [Node]> { _ in
    return [
        div([classAtr("row justify-content-md-center")], [
            br,
            div([classAtr("col-md-auto")], [
                a([classAtr("btn btn-dark"),
                   Attribute("href","#getting-started"),
                   Attribute("role","button"),
                   ], [.text("Getting Started")]),
                ]),
            div([classAtr("col-md-auto")], [
                a([classAtr("btn btn-outline-dark"),
                   Attribute("href","https://github.com/John-Connolly/concorde"),
                   Attribute("role","button"),
                   ], [.text("Github")]),
                ]),
            ])
    ]
}


private let sectionTitle = View<(String, String?), [Node]> { title in
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

private let pointsSection = View<(), [Node]> { _ in
    return [
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
            ])
    ]
}

private let descriptionSection = View<String, [Node]> { content in
    return [
        div([classAtr("row justify-content-md-center")], [
            div([classAtr("col-md-auto")], [
                br,
                h6([.text(content)]),
                ]),
            ]),
    ]
}

private let codeSection = View<String, [Node]> { content in
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

private let footerSection = View<(), [Node]> { _ in
    return [
        footer([classAtr("pt-4 my-md-5 pt-md-5 border-top")], [
            div([classAtr("container")], [
                span([classAtr("text-muted")], [.text("Concorde")])
                ])
            ])
    ]
}
