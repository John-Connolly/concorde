//
//  Bootstrap'.swift
//  Dev
//
//  Created by John Connolly on 2018-12-26.
//

import Foundation
import Html


func row(with nodes: [Node]) -> Node {
    return div([], [
        div([Attribute("class", "container-fluid")], [
            div([Attribute("class", "row")], nodes)
            ])])
}


func card(title: String, content: String) -> Node {
    return div([
        classAtr("card"),
        Attribute("style", "width: 18rem;"),
        ], [
            div([classAtr("card-body")], [
                h5([classAtr("card-title")],[.raw(title)]),
                p([classAtr("card-text")], [.raw(content)])
                ])

        ])
}

func card(with content: Node) -> Node {
    return div([classAtr("card")], [content])
}

func navBar(title: String) -> Node {
    return nav([
        Attribute("class", "navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow")]
        ,[
            a([Attribute("class","navbar-brand col-sm-3 col-md-2 mr-0")],[.raw(title)]),
            ul([Attribute("class","navbar-nav px-3")], [])
        ])
}

func classAtr<A>(_ value: String) -> Attribute<A> {
    return Attribute<A>("class", value)
}

func h4(content: String) -> Node {
    return div([], [br, h4([], [.raw(content)])])
}

let jquery = script([
    Attribute("src", "https://code.jquery.com/jquery-3.3.1.slim.min.js"),
    Attribute("integrity", "sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"),
    Attribute("crossorigin", "anonymous")
    ])

let boostrapCss: ChildOf<Tag.Head> = link([
    Attribute("rel", "stylesheet"),
    Attribute("href", "https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css"),
    Attribute("integrity", "sha384-9gVQ4dYFwwWSjIDZnLEWnxCjeSWFphJiwGPXr1jddIhOegiu1FwO5qRGvFXOdJZ4"),
    Attribute("crossorigin", "anonymous")
    ])

let boostrapJs: ChildOf<Tag.Head> = script([
    Attribute("src","https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js"),
    Attribute("integrity", "sha384-uefMccjFJAIv6A+rW+L4AHf99KvxDjWSu1z9VI8SKNVmz4sk7buKt/6v9KI65qnm"),
    Attribute("crossorigin", "anonymous")
    ])






func graph(items: [(String, Int)]) -> Node {
    let labels = items.map { $0.0 }.map { "\"" + $0 + "\"" }.joined(separator: ",")
    let values = items.map { "\($0.1)" }.joined(separator: ",")
    let js: String = """
var ctx = document.getElementById("myChart");
var myChart = new Chart(ctx, {
type: 'line',
data: {
labels: [\(labels)],
datasets: [{
data: [\(values)],
lineTension: 0,
backgroundColor: 'transparent',
borderColor: '#FFD62F',
borderWidth: 4,
pointBackgroundColor: '#FFD62F'
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
    return Node.element("script", [], [.raw(js)])
}


func table(header: [String], rows: [[String]]) -> Node {
    return div([classAtr("table-responsive")], [
        table([classAtr("table")], [
            thead([],[
                tr(header.map { th([Attribute("scope", "col")], [.text($0)]) }),
                ]),
            tbody([],
                  zip(rows, rows.indices).map { resource in
                    return tr([
                        th([Attribute("scope", "row")], [.text(resource.1.description)]),
                        ] + resource.0.map { td([.text($0)]) } )
                }
            )
            ])
        ])
}
