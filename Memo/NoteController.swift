//
//  NoteController.swift
//  Memo
//
//  Created by Ryan Bertrand on 03/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import UIKit
import SQLite3
import AVFoundation

class NoteController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    

    @IBOutlet weak var TBMisc: UIToolbar!
    @IBOutlet weak var UIContent: UITextView!
    @IBOutlet weak var UITime: UILabel!
    @IBOutlet weak var imageTake: UIImageView!
    //@IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var UITodo: UIButton!
    @IBOutlet weak var uiPicture: UIBarButtonItem!
    @IBOutlet weak var uiRecord: UIButton!
    
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var note: Note?
    var barButton: UIBarButtonItem!
    var imagePicker: UIImagePickerController!

    var audioRecorder:AVAudioRecorder!
    var db: OpaquePointer?
    
    var titleView = UITextField()
    
    var titleModif = false
    var contentModif = false
    var newTitle = ""
    var newContent = ""
    var images: [String] = ["photo", "photo"]
    
    @IBOutlet weak var toolBar: UIToolbar!

    enum ImageSource {
         case photoLibrary
         case camera
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDB()
        
        //Set current time in the header
        self.navigationItem.title = note?.title;
        UIContent.text = note?.content
        let format = DateFormatter()
        format.dateFormat = "dd MMMM yyyy | HH:mm"
        format.locale = Locale(identifier: "FR-fr")
        UITime.text = format.string(from: (note?.date)!)
        
        
        //btnDel.image  = UIImage(systemName: "return")
        UIContent.inputAccessoryView = TBMisc
        UIContent.delegate = self
        
        /*collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")*/
        
        
        titleView.text = note?.title
        titleView.frame = CGRect(x: 0, y: 0, width: 150, height: 1)
        titleView.textAlignment = NSTextAlignment.center
        navigationItem.titleView = titleView
        titleView.addTarget(self, action: #selector(textFieldDidChange(_:)),
        for: UIControl.Event.editingChanged)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        
        cell.configure(imageName: images[indexPath.row ])
    
        return cell
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let collectionViewWidth = collectionView.bounds.width/2
        
        let width = collectionViewWidth - 40
        
        return CGSize(width: width, height: width)
    }*/
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //Note title changed
    @objc func textFieldDidChange(_ textField: UITextField) {
        newTitle = String(textField.text!)
        print(newTitle)
        
        titleModif = true
    }
    
    //Initialization of local database
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
    
    //Detect when user get the focus of the content of the note, then hide the return button and show a closekeyboard button (Only usefull for Iphone, option available on the keyboard on Ipad)
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.navigationItem.setHidesBackButton(true, animated:true);
                //create a new button
        let button = UIButton(type: UIButton.ButtonType.custom) as! UIButton
        button.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        button.layoutIfNeeded()
        button.setNeedsLayout()
        if (button.imageView?.image == nil){
        //set image for button
        button.setImage(UIImage(named: "../img/hide-keyboard-button.png"), for: UIControl.State.normal)
            button.imageView?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
            button.imageView?.sizeToFit()
        //add function for button
        button.addTarget(self, action: "closeKeyboard", for: UIControl.Event.touchUpInside)
            
        
        
        
        barButton = UIBarButtonItem(customView: button)
        
        NSLayoutConstraint.activate([(barButton.customView!.widthAnchor.constraint(equalToConstant: 30)),(barButton.customView!.heightAnchor.constraint(equalToConstant: 30))])

        navigationItem.leftBarButtonItem = barButton
        }
        else {
            self.barButton.isEnabled = true
        }
    }
    
    //Close the keyboard, then remove the close keyboard button, then display return button
    @objc func closeKeyboard(){
        view.endEditing(true)
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(false, animated:true);
     }
    
   
   //MARK: - Picture and Camera
    //Allow to access to photoLibrary
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
              selectImageFrom(.photoLibrary)
      }

    @IBAction func startCamera(_ sender: UIBarButtonItem) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)

    }
    
    //Display the picture selected in the imageView
      func selectImageFrom(_ source: ImageSource){
          imagePicker =  UIImagePickerController()
          imagePicker.delegate = self
          switch source {
          case .camera:
              imagePicker.sourceType = .camera
          case .photoLibrary:
              imagePicker.sourceType = .photoLibrary
          }
          present(imagePicker, animated: true, completion: nil)
      }

    
      @IBAction func save(_ sender: AnyObject) {
          guard let selectedImage = imageTake.image else {
              print("Image not found!")
              return
          }
          UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
      }

      // Add image to Library
      @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
          if let error = error {
              // we got back an error!
              showAlertWith(title: "Save error", message: error.localizedDescription)
          } else {
              showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
          }
      }

    //MARK: Micro
    @IBAction func recordNoteVocal(_ sender: Any) {
        /*
        var audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVFoundation.AVAudioSessionCategoryPlayAndRecord, error: nil)
        audioSession.setActive(true, error: nil)

        var documents: AnyObject = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0]
        var str =  documents.stringByAppendingPathComponent("recordTest.caf")
        var url = NSURL.fileURLWithPath(str as String)

        var recordSettings = [AVFormatIDKey:kAudioFormatAppleIMA4,
            AVSampleRateKey:44100.0,
            AVNumberOfChannelsKey:2,AVEncoderBitRateKey:12800,
            AVLinearPCMBitDepthKey:16,
            AVEncoderAudioQualityKey:AVAudioQuality.Max.rawValue]

        println("url : \(url)")
        var error: NSError?

        audioRecorder = AVAudioRecorder(URL:url, settings: recordSettings, error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            audioRecorder.record()
        }*/
    }
    
    //Alert the user
      func showAlertWith(title: String, message: String){
          let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "OK", style: .default))
          present(ac, animated: true)
      }
    
    
    //Detect if the note content as been modified
    func textViewDidChange(_ textView: UITextView) {
        newContent = UIContent.text!
        if(newContent != note?.content){
            contentModif = true
        }
        else{
            contentModif = false
        }
    }
    
    func updateNote(){
        var queryString: String
        
        var stmt: OpaquePointer?
        
        let id = Int(note!.id!)
        
        if(titleModif == true){
            let dateFormatter: DateFormatter = {
                let _formatter = DateFormatter()
                _formatter.dateFormat = "dd MMMM yyyy | HH:mm"
                _formatter.locale = Locale(identifier: "FR-fr")
                return _formatter
            }()
            
            let newDate = dateFormatter.string(from: Date())
            
            queryString = "UPDATE Notes SET title = '\(newTitle)',date = '\(newDate)'  WHERE Id = \(id)"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting notes: \(errmsg)")
                return
            }
        }
        
        if(contentModif == true){
            let dateFormatter: DateFormatter = {
                let _formatter = DateFormatter()
                _formatter.dateFormat = "dd MMMM yyyy | HH:mm"
                _formatter.locale = Locale(identifier: "FR-fr")
                return _formatter
            }()
            
            let newDate = dateFormatter.string(from: Date())
            
            queryString = "UPDATE Notes SET content = '\(newContent)',date = '\(newDate)'  WHERE Id = \(id)"
            
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting notes: \(errmsg)")
                return
            }
        }
        
        contentModif = false
        titleModif = false
        navigationController?.popViewController(animated: true)
    }
    
    func saveNote(){
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO Notes (title, content, date) VALUES (?,?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        let title = newTitle
        let content = newContent
        
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
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func valider(){
        if (note?.id != nil){
            updateNote()
        }
        else{
            saveNote()
        }
    }
    
    @IBAction func deleteNote() {
        var stmt: OpaquePointer?
        
        if(self.note?.id != nil){
            //the insert query
            let queryString = "DELETE FROM Notes WHERE id = \(Int(self.note!.id!))"

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

        navigationController?.popViewController(animated: true)
    }
}

extension NoteController: UIImagePickerControllerDelegate{
//Pick a picture then close the picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true, completion: nil)
    
         
         guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        imageTake.image = selectedImage
    }
}
