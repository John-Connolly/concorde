//
//  Logs.swift
//  Dev
//
//  Created by John Connolly on 2019-01-07.
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

private let content = MainViewContent(tableContent: .init(tableHeader: ["#", "Task Name", "Error date",  "Log message"], content: [["Deploy", "156546520","Error: Could not complete operation"]]))

private let tableComponent = View<MainViewContent, [Node]> { content in
    return [
        card(with: table(header: content.tableContent.tableHeader,
                         rows: content.tableContent.content))
    ]
}


private let logs = (title.contramap { _ in "Logs" }
    <> tableComponent
    <> footerView.contramap { _ in })
    .map(flip(curry(baseView))(.logs) >>> pure)

func logsView() -> String {
    return render(logs.view(content))
}
