//
//  GlucoseReading.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-02-04.
//

import Foundation

struct GlucoseReading: Identifiable, Hashable {
    let id: UUID
    let timestamp: Date
    let mmol: Double
}
