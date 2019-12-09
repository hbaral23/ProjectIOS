//
//  NoteController.swift
//  Memo
//
//  Created by Ryan Bertrand on 03/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import UIKit

class NoteController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {
    

    @IBOutlet weak var TBMisc: UIToolbar!
    
    @IBOutlet weak var UIContent: UITextView!
    @IBOutlet weak var UITime: UILabel!
    
    @IBOutlet weak var UITodo: UIButton!
    @IBOutlet weak var UIPicture: UIButton!
    @IBOutlet weak var UIRecord: UIButton!
    
    var note: Note?
    var barButton: UIBarButtonItem!
    var imagePicker: UIImagePickerController!
    
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
        
        
        //btnDel.image  = UIImage(systemName: "return")
        UIContent.inputAccessoryView = TBMisc
        UIContent.delegate = self
            
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.navigationItem.setHidesBackButton(true, animated:true);
                //create a new button
        let button = UIButton(type: UIButton.ButtonType.custom) as! UIButton
        if (button.imageView?.image == nil){
        //set image for button
        button.setImage(UIImage(named: "../img/hide-keyboard-button.png"), for: UIControl.State.normal)
        //add function for button
        button.addTarget(self, action: "closeKeyboard", for: UIControl.Event.touchUpInside)
            
        
        button.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        
        barButton = UIBarButtonItem(customView: button)
        
        navigationItem.leftBarButtonItem = barButton
        }
        else {
            self.barButton.isEnabled = true
        }
    }
    
    @objc func closeKeyboard(){
        view.endEditing(true)

        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(false, animated:true);
    }
    
    @objc func closeTapped(){
        //view.endEditing(true)
        
        self.navigationItem.setHidesBackButton(false, animated:true);
    }
    
    @objc func addTapped(){
        
    }
    
    @objc func shareTapped(){
        
    }
    
    /*Camera*/
    @IBAction func takePhoto(_ sender: UIButton) {
        imagePicker =  UIImagePickerController()
        //imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

}
