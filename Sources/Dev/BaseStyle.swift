//
//  BaseStyle.swift
//  Dev
//
//  Created by John Connolly on 2019-01-07.
//

import Foundation
import concorde
import Html

func baseView(with nodes: [Node]) -> Node {
    let node = html([
        head(style: "dashboard.css"),
        body([
            navBar(title: "Swift-Q"),
            div([Attribute("class", "container-fluid")], [
                div([Attribute("class", "row")], [
                    sideBar(),
                    main([
                        Attribute("role", "main"),
                        classAtr("col-md-9 ml-sm-auto col-lg-10 px-4")
                        ], nodes)
                    ] )
                ]),
            jquery,
            graph(),
            graph(items: [])
            ])
        ])

    return node
}

func sideBar() -> Node {
    return nav([
        classAtr("col-md-2 d-none d-md-block bg-light sidebar")
        ], [
            div([classAtr("sidebar-sticky")], [
                ul([classAtr("nav flex-column")], [
                    sideBarItem(name: "Overview", isActive: true, href: "overview"),
                    sideBarItem(name: "Failed", isActive: false, href: "failed"),
                    sideBarItem(name: "Logs", isActive: false, href: "logs"),
                    ])
                ])
        ])

}

func sideBarItem(name: String, isActive: Bool, href: String) -> ChildOf<Tag.Ul> {
    return li([classAtr("nav-item")], [
        a(isActive ? [classAtr("nav-link active"), Attribute("href", href)] : [classAtr("nav-link"), Attribute("href", href)], [
            span([Attribute("data-feather", "home")], []),
            .text(name)
            ]
        )
        ])
}
