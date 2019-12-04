//
//  ListController.swift
//  Memo
//
//  Created by Ryan Bertrand on 03/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import UIKit
import SQLite3

class ListController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var notesTableView: UITableView!
    
    var db: OpaquePointer?
    
    var notes: [Note]?
    
    let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDB()
        
        notes = []
        
        for i in 1...10{
            notes?.append(Note(id: i, title: "note\(i)" , content: "Contenu note\(i)", pictures: [], date: Date()))
        }
        
        getData()
        
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        notesTableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
    }
    
    func initDB(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("NotesDatabase.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT,content TEXT, date DATE)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func getData(){
        notes?.removeAll()
        
        let queryString = "SELECT * FROM Notes"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        let dateFormatter: DateFormatter = {
            let _formatter = DateFormatter()
            _formatter.dateFormat = "dd MMMM yyyy | HH:mm"
            _formatter.locale = Locale(identifier: "FR-fr")
            return _formatter
        }()
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let content = String(cString: sqlite3_column_text(stmt, 2))
            let stringDate = String(cString: sqlite3_column_text(stmt, 3))
            let date = dateFormatter.date(from: stringDate);
            
            notes?.append(Note(id: Int(id), title: String(describing: title), content: content, pictures: [], date: date!))
        }
    }
    
    func addTestData(){
    
        for i in 1...10{
            //creating a statement
            var stmt: OpaquePointer?
            
            //the insert query
            let queryString = "INSERT INTO Notes (title, content, date) VALUES (?,?,?)"
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            let title = "note\(i)"
            let content = "contenu\(i)"
            
            let dateFormatter: DateFormatter = {
                let _formatter = DateFormatter()
                _formatter.dateFormat = "dd MMMM yyyy | HH:mm"
                _formatter.locale = Locale(identifier: "FR-fr")
                return _formatter
            }()
            
            let date = dateFormatter.string(from: Date())
            
            let SQLITE_TRANSIENT = unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite3_destructor_type.self)
            
            if sqlite3_bind_text(stmt, 1, title, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding title: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 2, content, -1, SQLITE_TRANSIENT ) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding content: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 3, date, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding date: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting notes: \(errmsg)")
                return
            }
                
        }
        
        print("notes saved successfully")
    }
    
    func deleteAllNotes(){
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "DELETE FROM Notes"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesTableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell") as! NoteTableViewCell
        
        let note = notes![indexPath.row]
        cell.configure(note: note)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let NoteController = mainStoryboard.instantiateViewController(withIdentifier: "NoteController") as! NoteController
        
        NoteController.note = self.notes?[indexPath.row]
        
        self.navigationController?.pushViewController(NoteController, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
