//
//  View.swift
//  Dev
//
//  Created by John Connolly on 2019-01-03.
//

import Foundation

struct View<D, N: Monoid> {
    let view: (D) -> N

    init(_ view: @escaping (D) -> N) {
        self.view = view
    }

    func map<S>(_ f: @escaping (N) -> S) -> View<D, S> {
        return View<D, S> { d in
            f(self.view(d))
        }
    }

    func contramap<B>(_ f: @escaping (B) -> D) -> View<B, N> {
        return .init { b in self.view(f(b)) }
    }
}

extension View: Monoid {
    static var e: View {
        return View { _ in N.e }
    }

    static func <>(lhs: View, rhs: View) -> View {
        return View { lhs.view($0) <> rhs.view($0) }
    }
}

func pure<A>(_ a: A) -> [A] {
    return [a]
}

precedencegroup Semigroup {
    associativity: left
}
infix operator <>: Semigroup

protocol Semigroup {
    static func <>(lhs: Self, rhs: Self) -> Self
}

protocol Monoid: Semigroup {
    static var e: Self { get }
}

extension Array: Monoid {
    static var e: Array { return  [] }
    static func <>(lhs: Array, rhs: Array) -> Array {
        return lhs + rhs
    }
}

import Html
import concorde


func render<D>(view: View<D, [Node]>, with data: D) -> String {
    return render(view.view(data))
}
