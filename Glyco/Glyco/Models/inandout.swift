//
//  inandout.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-04-25.
//
import Foundation
import CoreData

func glucoseAPICall(context: NSManagedObjectContext) {
    let gEntries = fetchGlucoseEntries(with: context).sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy HH:mm"
    
    var csvString = "Timestamp,Glucose\n" //header
    for g in gEntries {
        let timestamp = formatter.string(from: g.date ?? Date())
        let mgdl = g.value * 18  // mgdl convert
        csvString += "\(timestamp),\(mgdl)\n" //add each row as entry
    }
    
    // create file
    let fileManager = FileManager.default
    let fileURL: URL

    do {
        let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
        let fileURL = path.appendingPathComponent("GlucoseEntries.csv")
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
        print("error creating file")
    }
    
    // send to python backend
    
    let url = URL(string: "http://127.0.0.1:8000/predict")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
        //    STRUCTURE:
        //    POST /predict
        //    Content-Type: multipart/form-data; boundary=XYZ
        //
        //    --XYZ (separator)
        //    (file metadata)
        //    (file content)
        //    --XYZ-- (separator)
    let boundary = UUID().uuidString // separator string (ex: multipart data separated by 'xxx')
    request.setValue("multipart/form-data; boundary=\(boundary)",
                     forHTTPHeaderField: "Content-Type") // Set structure/framework of what will be sent
    
    var body = Data() // create data
    let fileData = try! Data(contentsOf: fileURL) // file name + content
    
    body.append("--\(boundary)\r\n".data(using: .utf8)!) // boundary data start
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"glucose.csv\"\r\n".data(using: .utf8)!) // header (file description)
    body.append("Content-Type: text/csv\r\n\r\n".data(using: .utf8)!) // file type + end header
    body.append(fileData) // add data
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!) // boundary data end // close request
    // all this data is in binary

    URLSession.shared.uploadTask(with: request, from: body) //send data
    { data, _, error in // when python sends data back (callback)
        if let data = data { // check if data exists
            print(String(data: data, encoding: .utf8)!) // print return for now (converts back from binary)
        }
    }.resume() // starts request
}
