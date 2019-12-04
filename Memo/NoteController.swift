//
//  NoteController.swift
//  Memo
//
//  Created by Ryan Bertrand on 03/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import UIKit

class NoteController: UIViewController {
    
    @IBOutlet weak var TBMisc: UIToolbar!
    
    @IBOutlet weak var UIContent: UITextView!
    @IBOutlet weak var UITime: UILabel!
    
    @IBOutlet weak var UITodo: UIButton!
    @IBOutlet weak var UIPicture: UIButton!
    @IBOutlet weak var UIRecord: UIButton!
    
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(note)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(shareTapped))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(addTapped))
//
//        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
//        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
//        navigationItem.rightBarButtonItems = [add, share]
        
        self.navigationItem.title = note?.title;
        UIContent.text = note?.content
        let format = DateFormatter()
        format.dateFormat = "dd MMMM yyyy | HH:mm"
        format.locale = Locale(identifier: "FR-fr")
        UITime.text = format.string(from: (note?.date)!)
        
        
        let bar = UIToolbar()
        let reset = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(closeTapped))
        bar.items = [reset]
        bar.sizeToFit()
        UIContent.inputAccessoryView = bar
    }
    
    
    
    @objc func closeTapped(){
        
    }
    
    @objc func addTapped(){
        
    }
    
    @objc func shareTapped(){
        
    }
}
