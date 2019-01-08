//
//  Dashboard.swift
//  Dev
//
//  Created by John Connolly on 2018-12-24.
//

import Foundation
import concorde
import Html

struct DashBoardData {
    let stats: RedisStats
    let proccessed: ProcessedStats
    let consumers: [ConsumerInfo]
}

private let dashBoard: View<DashBoardData, [Node]> = (title.contramap { _ in "Redis Overview" }
    <> redisStatsUsageView.contramap { $0.stats }
    <> redisStatsView.contramap { $0.stats }
    <> statsRowView.contramap { $0.proccessed }
    <> chartView.contramap { _ in }
    <> canvasView.contramap { _ in }
    <> workerTableView.contramap { $0.consumers }
    <> footerView.contramap { _ in })
    .map(flip(curry(baseView))(.overview) >>> pure)


func dashBoardView(data: DashBoardData) -> String {
    return render(dashBoard.view(data))
}

let redisStatsUsageView = View<RedisStats, [Node]> { content in
    return [
        row(with: [
            div([classAtr("col-sm")], [
                card(title: "Blocked clients", content: content.formattedBlocked),
                ]),
            div([classAtr("col-sm")], [
                card(title: "Connected clients", content: content.formattedClients),
                ]),
            div([classAtr("col-sm")], [
                card(title: "Used memory", content: content.usedMemoryHuman),
                ])
            ]),
        br
    ]
}


let redisStatsView = View<RedisStats, [Node]> { content in
    return [
        row(with: [
            div([classAtr("col-sm")], [
                card(title: "Uptime", content: content.formattedUptime),
                ]),
            div([classAtr("col-sm")], [
                card(title: "Total Memory", content: content.totalMemory),
                ]),
            div([classAtr("col-sm")], [
                card(title: "Redis Version", content: content.serverVersion),
                ])
            ]),
        br
    ]
}


// Remove this redundent code
let statsRowView = View<ProcessedStats, [Node]> { content in
    return [
        row(with: [
            div([classAtr("col-sm")], [
                card(title: "Successful", content: content.total),
                ]),
            div([classAtr("col-sm")], [
                card(title: "Queued", content: content.queued),
                ]),
            div([classAtr("col-sm")], [
                card(title: "Failed", content: content.failed),
                ])
            ]),
        ]
}

private let workerTableView = View<[ConsumerInfo], [Node]> { content in
    let rows = content.map { [$0.info.hostname, "Good", $0.beat.description,] }
    return [
        card(with: table(header: ["#", "Consumer", "Health", "Last Heartbeat"], rows: rows)),
        ]
}

private let canvasView = View<(), [Node]> {
    return [
        canvas([
            classAtr("my-4 w-100"),
            Attribute("id", "myChart"),
            Attribute("width", "900"),
            Attribute("height", "380"),
            ], [])
    ]
}


private let title = View<String, [Node]> { content in
    return [
        br,
        h3([classAtr("h2")], [.text(content)]),
        ]
}

private let chartView = View<(), [Node]> {
    return [
        div(
            [classAtr("d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom")], [
                h1([classAtr("h2")], [.text("History")]),
                div([classAtr("btn-toolbar mb-2 mb-md-0")], [
                    div([classAtr("btn-group mr-2")], [
                        button([classAtr("btn btn-sm btn-outline-secondary")], [.text("Share")]),
                        button([classAtr("btn btn-sm btn-outline-secondary")], [.text("Export")]),
                        ])
                    ]),
                ])
    ]
}

func graph() -> Node {
    return script([Attribute("src","https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js")],"")
}
