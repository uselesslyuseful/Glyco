//
//  inandout.swift
//  Glyco
//
//  Created by Vincent Pham on 2026-04-25.
//
import Foundation
import CoreData

struct PredictionResponse: Decodable {
    let predictions: [Prediction]
}

struct Prediction: Decodable, Identifiable {
    let timestamp: Date
    let glucose: Double

    var id: Date { timestamp }
}

func glucoseAPICall(context: NSManagedObjectContext) async throws -> [Prediction]{
    let gEntries = fetchGlucoseEntries(with: context).sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy HH:mm"
    formatter.timeZone = TimeZone(identifier: "UTC")
    
    var csvString = "Timestamp,Glucose\n" //header
    for g in gEntries {
        let timestamp = formatter.string(from: g.date ?? Date())
        let mgdl = g.value * 18 // mgdl convert
        csvString += "\(timestamp),\(mgdl)\n" //add each row as entry
    }
    // create file
    //    let fileManager = FileManager.default
    
    //    do {
    //        let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
    //        let fileURL = path.appendingPathComponent("GlucoseEntries.csv")
    //        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
    //
    //        // send to python backend
    //
    let url = URL(string: "https://glyco-glucoseapiserver.onrender.com/predict")!
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
    let fileData = csvString.data(using: .utf8)!
    body.append("--\(boundary)\r\n".data(using: .utf8)!) // boundary data start
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"glucose.csv\"\r\n".data(using: .utf8)!) // header (file description)
    body.append("Content-Type: text/csv\r\n\r\n".data(using: .utf8)!) // file type + end header
    body.append(fileData) // add data
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!) // boundary data end // close request
    // all this data is in binary
    
    do{
        let (data, _) = try await URLSession.shared.upload(for: request, from: body)
        
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(PredictionResponse.self, from: data)
        
        print(decoded.predictions)
        return decoded.predictions
    }
    catch{
        print("glucoseAPIthing failed", error)
        return []
    }
    //    } catch {
    //        print("error creating file")
    //    } 
}
