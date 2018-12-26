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






func graph(items: [(String, String)]) -> Node {
//    let labels = items.map { $0.0 + "," }.reduce("", +)
    let js: StaticString = """
var ctx = document.getElementById("myChart");
var myChart = new Chart(ctx, {
type: 'line',
data: {
labels: ["hello"],
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
    return script(js)
}

//<div class="table-responsive">
//<table class="table table-striped table-sm">
//<thead>
//<tr>


func table() -> Node {
    return div([classAtr("table-responsive")], [
        table([classAtr("table")], [
            thead([],[
//                    tr([
//                        th([], [.raw("#")])
//                    ])
                ])
            ])
        ])
}
