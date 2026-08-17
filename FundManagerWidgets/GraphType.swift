//
//  GraphType.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import AppIntents

enum GraphType: String, AppEnum, Codable {

    case line
    case bar

    static var typeDisplayRepresentation =
        TypeDisplayRepresentation(
            name: "Graph Type"
        )

    static var caseDisplayRepresentations: [
        GraphType: DisplayRepresentation
    ] = [
        .line: DisplayRepresentation(title: "Line"),
        .bar: DisplayRepresentation(title: "Bar")
    ]
}
