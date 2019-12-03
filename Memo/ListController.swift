//
//  ListController.swift
//  Memo
//
//  Created by Ryan Bertrand on 03/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import UIKit

class ListController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var notesTableView: UITableView!
    
    var notes: [Note]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notes = []
        
        for i in 1...10{
            notes?.append(Note(title: "note\(i)" , content: "Contenu note\(i)", pictures: []))
        }
        
        notesTableView.delegate = self
        notesTableView.dataSource = self
        
        notesTableView.register(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteTableViewCell")
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
        /*let pointStationsViewController = mainStoryboard.instantiateViewController(withIdentifier: "pointStationsViewController") as! PointStationsViewController
        
        //TODO: Ici, on va passer au pointStationsViewController les informations sur le netwok choisi, afin de pouvoir afficher les différentes stations sur la carte
        
        pointStationsViewController.network = self.locationPoints?[indexPath.row]
        
        self.navigationController?.pushViewController(pointStationsViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)*/
    }
}
