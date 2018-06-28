//
//  PrecedenceGroups.swift
//  Concorde
//
//  Created by John Connolly on 2018-06-02.
//

import Foundation

precedencegroup MonadicPrecedenceLeft {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup ParserPrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}
