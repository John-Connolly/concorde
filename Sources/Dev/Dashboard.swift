//
//  Dashboard.swift
//  Dev
//
//  Created by John Connolly on 2018-12-24.
//

import Foundation
import concorde
import Html

func dashBoardView() -> String {
    let node = html([
        head(style: "dashboard.css"),
        body([
            navBar(title: "Swift-Q"),
            div([Attribute("class", "container-fluid")], [
                div([Attribute("class", "row")], [
                    sideBar(),
                    mainView(title: "Overview"),
                    ])
                ]),

            jquery(),
            graph(),
            graph2()

            ])
        ])

    return render(node)
}


func navBar(title: String) -> Node {
    return nav([
        Attribute("class", "navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow")]
        ,[
            a([Attribute("class","navbar-brand col-sm-3 col-md-2 mr-0")],[.raw(title)]),
            ul([Attribute("class","navbar-nav px-3")], [])
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


func classAtr<A>(_ value: String) -> Attribute<A> {
    return Attribute<A>("class", value)
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



func mainView(title: String) -> Node {
    return main([
        Attribute("role", "main"),
        classAtr("col-md-9 ml-sm-auto col-lg-10 px-4")
        ], [
         div(
            [classAtr("d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom")], [
                h1([classAtr("h2")], [.raw(title)]),
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


//<script>window.jQuery || document.write('<script src="../../../../assets/js/vendor/jquery-slim.min.js"><\/script>')</script>
//<script src="../../../../assets/js/vendor/popper.min.js"></script>
//<script src="../../../../dist/js/bootstrap.min.js"></script>

func jquery() -> Node {
    return script([
        Attribute("src", "https://code.jquery.com/jquery-3.3.1.slim.min.js"),
        Attribute("integrity", "sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"),
        Attribute("crossorigin", "anonymous")
        ])
}

//let str: StaticString =
//"""
//window.jQuery || document.write('<script src="../../../../assets/js/vendor/jquery-slim.min.js"></\\script>')
//"""
//
//func rand() -> Node {
//    return script(str)
//}

func popperJs() -> Node {
    return script([
        Attribute("src", "../../../../assets/js/vendor/popper.min.js"),
        ])
}


