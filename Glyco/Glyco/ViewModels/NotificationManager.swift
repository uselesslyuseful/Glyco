//
//  NotificationManager.swift
//  Glyco
//
//  Created by Susan Zheng on 2026-05-07.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    private var lastAlertDate: Date?
    private let cooldown: TimeInterval = 15 * 60 // 15 minutes

    static let shared = NotificationManager()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }

    func sendGlucoseAlert(title: String, body: String) {

        if let last = lastAlertDate,
           Date().timeIntervalSince(last) < cooldown {
            return
        }

        lastAlertDate = Date()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
