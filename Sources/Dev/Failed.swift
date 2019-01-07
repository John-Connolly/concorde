//
//  Failed.swift
//  Dev
//
//  Created by John Connolly on 2018-12-25.
//

import Foundation
import concorde
import Html

private let title = View<String, [Node]> { content in
    return [
        br,
        h3([classAtr("h2")], [.text(content)]),
        br,
    ]
}

private let tableComponent = View<MainViewContent, [Node]> { content in
    return [
        card(with: table(header: content.tableContent.tableHeader,
                         rows: content.tableContent.content))
    ]
}



struct MainViewContent {
    let tableContent: TableContent

    struct TableContent {
        let tableHeader: [String]
        let content: [[String]]
    }

}

let content = MainViewContent(tableContent: .init(tableHeader: ["#", "Worker", "Failed Count"], content: [["Worker 1", "hello"]]))

private let failed = (title.contramap { _ in "Failed" }
    <> tableComponent
    <> footerView.contramap { _ in })
    .map(flip(curry(baseView))(.failed) >>> pure)

func failedView() -> String {
    return render(failed.view(content))
}

/// Include job types!
