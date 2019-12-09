//
//  NoteController.swift
//  Memo
//
//  Created by Ryan Bertrand on 03/12/2019.
//  Copyright © 2019 Hugo Baral. All rights reserved.
//

import UIKit


class NoteController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    

    @IBOutlet weak var TBMisc: UIToolbar!
    @IBOutlet weak var UIContent: UITextView!
    @IBOutlet weak var UITime: UILabel!
    @IBOutlet weak var imageTake: UIImageView!
    
    @IBOutlet weak var UITodo: UIButton!
    @IBOutlet weak var UIPicture: UIButton!
    @IBOutlet weak var UIRecord: UIButton!
    
    var note: Note?
    var barButton: UIBarButtonItem!
    var imagePicker: UIImagePickerController!

    enum ImageSource {
         case photoLibrary
         case camera
     }
    
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
    
    @objc func closeKeyboard(){
        view.endEditing(true)

        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(false, animated:true);
     }
    
    @objc func closeTapped(){
        //view.endEditing(true)
        
        self.navigationItem.setHidesBackButton(false, animated:true);
        self.view.addSubview(TBMisc)

        TBMisc.translatesAutoresizingMaskIntoConstraints = false
        TBMisc.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        TBMisc.widthAnchor.constraint(equalToConstant: 50).isActive = true
        TBMisc.heightAnchor.constraint(equalToConstant: 50).isActive = true
        TBMisc.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        //self.navigationController?.navigationBar = TBMisc
    }
    
    @objc func addTapped(){
        
    }
    
    @objc func shareTapped(){
        
    }
    
    
    /*Camera*/
   //MARK: - Take image
      @IBAction func takePhoto(_ sender: UIBarButtonItem) {
          guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
              selectImageFrom(.photoLibrary)
              return
          }
          selectImageFrom(.camera)
      }

    @IBAction func startCamera(_ sender: UIBarButtonItem) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)

    }
    
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

      //MARK: - Saving Image here
      @IBAction func save(_ sender: AnyObject) {
          guard let selectedImage = imageTake.image else {
              print("Image not found!")
              return
          }
          UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
      }

      //MARK: - Add image to Library
      @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
          if let error = error {
              // we got back an error!
              showAlertWith(title: "Save error", message: error.localizedDescription)
          } else {
              showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
          }
      }

      func showAlertWith(title: String, message: String){
          let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
          ac.addAction(UIAlertAction(title: "OK", style: .default))
          present(ac, animated: true)
      }
}

extension NoteController: UIImagePickerControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        imageTake.image = selectedImage
    }
}
