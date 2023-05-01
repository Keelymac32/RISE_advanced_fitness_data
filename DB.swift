//
//  DB.swift
//  RISEapp
//
//  Created by Keelyn McNamara on 2/26/23.
//

import Foundation
import SQLite3

public class DB{
    var DB: OpaquePointer?
    var path: String = "myHeathData.sqlite"
    
    init(){
        self.DB = createDB()
        self.createTable()
        //self.delete()
        //self.insert(date: Date(), recovery: 95.6, intensities: [1,2,8], strain: 7.5)
        // print("printing query 1")
    }
    
    
    func createDB() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil , create: false).appendingPathComponent(path)
        
        var db: OpaquePointer? = nil
        
        if sqlite3_open(filePath.path, &db) != SQLITE_OK{
            print("There is an error in creating the data base")
            return nil
        }
        else{
            print("Data Base Has been Created")
            return db
        }
    }
    
    
    func createTable(){
        let query = "CREATE TABLE IF NOT EXISTS healthdata(date TEXT PRIMARY KEY, recovery DOUBLE, intensities TEXT, strain DOUBLE)"
        
        var createTable : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.DB, query, -1, &createTable, nil) == SQLITE_OK{
            if sqlite3_step(createTable) == SQLITE_DONE{
                print("Table Created Sucessfully")
            } else{
               print("Table Creation Failled")
            }
        }
        else{
            print("Prepapration Failed")
        }
        
    }
    
    func insert(date: Date, recovery: Double, intensities: [Double], strain: Double){
        
        //Setting up passed parameters to be formated into query
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "Y,MM,dd"
        let dbDate = dateformatter.string(from: date).description
                
        var dbIntensities = intensities.description
        dbIntensities.remove(at:dbIntensities.index(before: dbIntensities.endIndex))
        dbIntensities.remove(at: dbIntensities.startIndex)
                
        let query = "INSERT INTO healthdata (date, recovery, intensities, strain) VALUES(?,?,?,?)"
        
        var statement : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.DB, query, -1, &statement, nil) == SQLITE_OK{
            sqlite3_bind_text(statement, 1, (dbDate as NSString).utf8String,-1,nil)
            sqlite3_bind_double(statement, 2, recovery)
            sqlite3_bind_text(statement, 3, (dbIntensities as NSString).utf8String,-1,nil)
            sqlite3_bind_double(statement, 4, strain)
            if sqlite3_step(statement) == SQLITE_DONE{
                print("Insert Successful")
            }
            else{
                print("Insert Not Sucessful")}}
        
        else{
            print("Query Is Not Completed ")
            
        }
        
    }
    
    func query() {
        var queryStatement: OpaquePointer? = nil
        let queryStatementString = "SELECT * FROM healthdata;"
        
        
        if sqlite3_prepare_v2(self.DB, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        print("\n")
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
          
          let queryResultCol0 = sqlite3_column_text(queryStatement, 0)
          let date = String(cString: queryResultCol0!)
         
          let recovery = sqlite3_column_double(queryStatement, 1)
            
          let queryResultCol3 = sqlite3_column_text(queryStatement, 2)
          let intensities = String(cString: queryResultCol3!)
           
          let strain = sqlite3_column_double(queryStatement, 3)
          
        
            print("\(String(describing: date)) | \(recovery) | \(intensities) | \(strain) ")
        }
      }
      sqlite3_finalize(queryStatement)
    }
    
    
    
    
    func updateRecovery(newRec: Double){
        print("Inside DB Update Recovery")
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "Y,MM,dd"
        let date = Date()
        let dbDate = dateformatter.string(from: date).description
        
        let recovery = newRec
        let updateStatementString = "UPDATE healthdata SET recovery = \(recovery) WHERE date = '\(dbDate)';"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(self.DB, updateStatementString, -1, &updateStatement, nil) ==
            SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement is not prepared")
        }
        sqlite3_finalize(updateStatement)
        query()
    }
    
    func updateIntensities(newInten: [Double]){
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "Y,MM,dd"
        let date = Date()
        let dbDate = dateformatter.string(from: date).description
        
        var intensity = newInten.description
        intensity.remove(at:intensity.index(before: intensity.endIndex))
        intensity.remove(at: intensity.startIndex)
        
        let updateStatementString = "UPDATE healthdata SET intensities = '\(intensity)' WHERE date = '\(dbDate)';"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(self.DB, updateStatementString, -1, &updateStatement, nil) ==
              SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
              print("\nSuccessfully updated row.")
            } else {
              print("\nCould not update row.")
            }
          } else {
            print("\nUPDATE statement is not prepared")
          }
          sqlite3_finalize(updateStatement)
        }
      
    func updateStrain(newStrain: Double){
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "Y,MM,dd"
        let date = Date()
        let dbDate = dateformatter.string(from: date).description
        
        let strain = newStrain.description
        let updateStatementString = "UPDATE healthdata SET strain = \(strain) WHERE date = '\(dbDate)';"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(self.DB, updateStatementString, -1, &updateStatement, nil) ==
              SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
              print("\nSuccessfully updated row.")
            } else {
              print("\nCould not update row.")
            }
          } else {
            print("\nUPDATE statement is not prepared")
          }
          sqlite3_finalize(updateStatement)
        }
    
    
    func delete(){
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "Y,MM,dd"
        let date = Date()
        let dbDate = dateformatter.string(from: date).description
            
        let deleteStatementString = "DELETE FROM healthdata WHERE date = '\(dbDate)';"
        var deleteStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(self.DB, deleteStatementString, -1, &deleteStatement, nil) ==
              SQLITE_OK {
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
              print("Successfully deleted row.")
            } else {
              print("Could not delete row.")
            }
          } else {
            print("DELETE statement could not be prepared")
          }
          
          sqlite3_finalize(deleteStatement)
        
    }
    
    
    func exists() -> Bool {
      var exist = false
      let dateformatter = DateFormatter()
      dateformatter.dateFormat = "Y,MM,dd"
      let date = Date()
      let dbDate = dateformatter.string(from: date).description
    
      let queryStatementString = "SELECT date FROM healthdata WHERE date = '\(dbDate)';"
        
      var queryStatement: OpaquePointer?
         if sqlite3_prepare_v2(DB, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
             if sqlite3_step(queryStatement) == SQLITE_ROW {
                 print("Query returned result")
                 exist = true
             } else {
                 print("Query returned no results.")
                 exist = false}
             
         } else {
           let errorMessage = String(cString: sqlite3_errmsg(DB))
           print("Query is not prepared \(errorMessage)")
           exist = false
         }
         sqlite3_finalize(queryStatement)
         return exist
       }

    
    func getDays() -> [String] {
        let day7 = Date()
        let day6 = Calendar.current.date(byAdding: .day, value: -1, to: day7)
        let day5 = Calendar.current.date(byAdding: .day, value: -1, to: day6!)
        let day4 = Calendar.current.date(byAdding: .day, value: -1, to: day5!)
        let day3 = Calendar.current.date(byAdding: .day, value: -1, to: day4!)
        let day2 = Calendar.current.date(byAdding: .day, value: -1, to: day3!)
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day2!)
        
        let datesOfTheWeek = [day7,day6,day5,day4,day3,day2,day1]
        var daysOfTheWeek: [String] = []
        
        
        for date in datesOfTheWeek{
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "Y,MM,dd"
            let finalday = dateformatter.string(from: date!).description
            daysOfTheWeek.append(finalday)
        }
        return daysOfTheWeek
    }
    
    func getDaysAbrv() -> [String] {
        let day7 = Date()
        let day6 = Calendar.current.date(byAdding: .day, value: -1, to: day7)
        let day5 = Calendar.current.date(byAdding: .day, value: -1, to: day6!)
        let day4 = Calendar.current.date(byAdding: .day, value: -1, to: day5!)
        let day3 = Calendar.current.date(byAdding: .day, value: -1, to: day4!)
        let day2 = Calendar.current.date(byAdding: .day, value: -1, to: day3!)
        let day1 = Calendar.current.date(byAdding: .day, value: -1, to: day2!)
        
        let datesOfTheWeek = [day7,day6,day5,day4,day3,day2,day1]
        var daysOfTheWeek: [String] = []
        
        
        for date in datesOfTheWeek{
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "MM,dd"
            let finalday = dateformatter.string(from: date!).description
            daysOfTheWeek.append(finalday)
        }
        return daysOfTheWeek
    }
    
    
    
    func weekQueryRecovery() -> [Double] {
            
        let daysOfTheWeek = getDays()
        
        var weeklyStringRecovery: [Double] = []
        
        var queryStatement: OpaquePointer? = nil
        
        let queryStatementString = "SELECT * FROM healthdata WHERE date = '\(daysOfTheWeek[0])' or date = '\(daysOfTheWeek[0])' or date = '\(daysOfTheWeek[1])' or date = '\(daysOfTheWeek[2])' or date = '\(daysOfTheWeek[3])' or date = '\(daysOfTheWeek[4])' or date = '\(daysOfTheWeek[5])' or date = '\(daysOfTheWeek[6])';"
        
    
        if sqlite3_prepare_v2(self.DB, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        print("\n")
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
          
          let queryResultCol0 = sqlite3_column_text(queryStatement, 0)
          let date = String(cString: queryResultCol0!)
         
          let recovery = sqlite3_column_double(queryStatement, 1)
            weeklyStringRecovery.append(recovery)
            
          let queryResultCol3 = sqlite3_column_text(queryStatement, 2)
          let intensities = String(cString: queryResultCol3!)
           
          let strain = sqlite3_column_double(queryStatement, 3)
          
        
            print("\(String(describing: date)) | \(recovery) | \(intensities) | \(strain) ")
            print(weeklyStringRecovery)
        }
      }
      sqlite3_finalize(queryStatement)
      return weeklyStringRecovery
    }

    func weekQueryIntensities() -> [Double] {
            
        let daysOfTheWeek = getDays()
        
        var weeklyStringIntensity: [String] = []
        var weeklyIntensity: [Double] = []
        
        var queryStatement: OpaquePointer? = nil
        
        let queryStatementString = "SELECT * FROM healthdata WHERE date = '\(daysOfTheWeek[0])' or date = '\(daysOfTheWeek[0])' or date = '\(daysOfTheWeek[1])' or date = '\(daysOfTheWeek[2])' or date = '\(daysOfTheWeek[3])' or date = '\(daysOfTheWeek[4])' or date = '\(daysOfTheWeek[5])' or date = '\(daysOfTheWeek[6])';"
        
    
        if sqlite3_prepare_v2(self.DB, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        print("\n")
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
          
          let queryResultCol0 = sqlite3_column_text(queryStatement, 0)
            
          let queryResultCol3 = sqlite3_column_text(queryStatement, 2)
          let intensities = String(cString: queryResultCol3!)
          weeklyStringIntensity.append(intensities)
                     
        }
            weeklyIntensity = convertToDouble(StringList: weeklyStringIntensity)
      }
      sqlite3_finalize(queryStatement)
      return weeklyIntensity
    }
    
    
    func weekQueryStrain() -> [Double] {
            
        let daysOfTheWeek = getDays()
        
        var weeklyStrain: [Double] = []
        
        var queryStatement: OpaquePointer? = nil
        
        let queryStatementString = "SELECT * FROM healthdata WHERE date = '\(daysOfTheWeek[0])' or date = '\(daysOfTheWeek[0])' or date = '\(daysOfTheWeek[1])' or date = '\(daysOfTheWeek[2])' or date = '\(daysOfTheWeek[3])' or date = '\(daysOfTheWeek[4])' or date = '\(daysOfTheWeek[5])' or date = '\(daysOfTheWeek[6])';"
        
    
        if sqlite3_prepare_v2(self.DB, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        print("\n")
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
        
           
          let strain = sqlite3_column_double(queryStatement, 3)
            weeklyStrain.append(strain)
          
        }
      }
      sqlite3_finalize(queryStatement)
      return weeklyStrain
    }
    
    func setXAxis() -> [String]{
        var daysOfWeek: [String] = []
        var queryStatement: OpaquePointer? = nil
        let queryStatementString = "SELECT * FROM ( SELECT * FROM healthdata ORDER BY date DESC LIMIT 7) ORDER BY date ASC;"
       
        if sqlite3_prepare_v2(self.DB, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        print("\n")
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
        
          let queryResultCol0 = sqlite3_column_text(queryStatement, 0)
          var daysuncut = String(cString: queryResultCol0!)
          var days = String(daysuncut.dropFirst(5))
          daysOfWeek.append(days)
        }
      }
      sqlite3_finalize(queryStatement)
      return daysOfWeek
    }
    
    
    func setStrainGraphs() -> [Double] {
        var weeklyStrain: [Double] = []
        var daysOfWeek: [String] = []
        
        var queryStatement: OpaquePointer? = nil
        let queryStatementString = "SELECT * FROM ( SELECT * FROM healthdata ORDER BY date DESC LIMIT 7) ORDER BY date ASC;"
       
        if sqlite3_prepare_v2(self.DB, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        print("\n")
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
        
          let queryResultCol0 = sqlite3_column_text(queryStatement, 0)
          let days = String(cString: queryResultCol0!)
            
            
          let strain = sqlite3_column_double(queryStatement, 3)
            weeklyStrain.append(strain)
            daysOfWeek.append(days)
        }
      }
      sqlite3_finalize(queryStatement)
      return weeklyStrain
    }

    
    
    
    
    
    
    
    func convertToDouble(StringList: [String]) -> [Double]{
        
        let str = StringList.joined(separator: ", ")
        let array = str.components(separatedBy: ", ")
        print(array)
        var doubles: [Double] = []
        
        for string in array {
            if string == "" {
                doubles.append(0.0)
                print(0.0)
            }
            else{
                doubles.append(Double(string)!)
            }
        }
        return doubles
    }
    
    
} //end
