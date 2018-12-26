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
}

func dashBoardView(stats: RedisStats) -> String {
    let node = html([
        head(style: "dashboard.css"),
        body([
            navBar(title: "Swift-Q"),
            div([Attribute("class", "container-fluid")], [
                div([Attribute("class", "row")], [
                    sideBar(),
                    mainView(title: "Overview", node: redisStatsView(stats)),
                    ])
                ]),

            jquery,
            graph(),
            graph2()

            ])
        ])

    return render(node)
}




func redisStatsView(_ stats: RedisStats) -> Node {
    return row(with: [
        div([classAtr("col-sm")], [
            card(title: "Blocked clients", content: stats.formattedBlocked),
            ]),
        div([classAtr("col-sm")], [
            card(title: "Connected clients", content: stats.formattedClients),
            ]),
        div([classAtr("col-sm")], [
            card(title: "Used memory", content: stats.usedMemoryHuman),
            ])
        ])
}

func mainStatsRow() -> Node {
    return row(with: [
        div([classAtr("col-sm")], [
            card(title: "Successful", content: "34"),
            ]),
        div([classAtr("col-sm")], [
            card(title: "Queued", content: "34"),
            ]),
        div([classAtr("col-sm")], [
            card(title: "Failed", content: "34"),
            ])
        ])
}

func containerFluid() -> ([Node]) -> Node {
    return { nodes in
        div([Attribute("class", "container-fluid")], nodes)
    }
}

func row() -> ([Node]) -> Node {
    return { nodes in
        div([Attribute("class", "row")], nodes)
    }
}


func sideBar() -> Node {
    return nav([
        classAtr("col-md-2 d-none d-md-block bg-light sidebar")
        ], [
            div([classAtr("sidebar-sticky")], [
                ul([classAtr("nav flex-column")], [
                    sideBarItem(name: "Overview"),
                    sideBarItem(name: "Failed"),
                    sideBarItem(name: "Logs"),
                    ])
                ])
        ])

}

func sideBarItem(name: String) -> ChildOf<Tag.Ul> {
    return li([classAtr("nav-item")], [
        a([classAtr("nav-link active")], [
            span([Attribute("data-feather","home")], []),
            .raw(name)
            ]
        )
        ])
}

func mainView(title: String, node: Node) -> Node {
    return main([
        Attribute("role", "main"),
        classAtr("col-md-9 ml-sm-auto col-lg-10 px-4")
        ], [
            br,
            h3([classAtr("h2")], [.raw(title)]),
            node,
            br,
            mainStatsRow(),
            div(
                [classAtr("d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom")], [
                    h1([classAtr("h2")], [.raw("History")]),
                    div([classAtr("btn-toolbar mb-2 mb-md-0")], [
                        div([classAtr("btn-group mr-2")], [
                            button([classAtr("btn btn-sm btn-outline-secondary")], [.raw("Share")]),
                            button([classAtr("btn btn-sm btn-outline-secondary")], [.raw("Export")]),
                            ])
                        ]),
                    ]),

            canvas(),
            ])
}

func canvas() -> Node {
    return canvas([
        classAtr("my-4 w-100"),
        Attribute("id", "myChart"),
        Attribute("width", "900"),
        Attribute("height", "380"),
        ], [])

}

func graph() -> Node {
    return script([Attribute("src","https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.1/Chart.min.js")],"")
}

let js: StaticString = """
var ctx = document.getElementById("myChart");
var myChart = new Chart(ctx, {
type: 'line',
data: {
labels: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
datasets: [{
data: [15339, 21345, 18483, 24003, 23489, 24092, 12034],
lineTension: 0,
backgroundColor: 'transparent',
borderColor: '#007bff',
borderWidth: 4,
pointBackgroundColor: '#007bff'
}]
},
options: {
scales: {
yAxes: [{
ticks: {
beginAtZero: false
}
}]
},
legend: {
display: false,
}
}
});

"""
func graph2() -> Node {
    return script(js)
}


