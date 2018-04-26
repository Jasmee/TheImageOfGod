//
//  ViewController.swift
//  TheImageOfGod
//
//  Created by Jasmee Sengupta on 10/03/18.
//  Copyright © 2018 Jasmee Sengupta. All rights reserved.
//
// check image view did change image - didset property observer or addobserver
// button image change method, construct only once
// button height width etc enum or struct
// turn into a proper app
// 2 image views or seteditable ture?

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var originalImageView: ImageView!
    @IBOutlet weak var filteredImageView: ImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var buttonsArray = [UIButton]()
    
    // enum later
    var filterTypes = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]

    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //originalImageView.image = UIImage(named: "god") // set from storyboard
        addFilters()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // objc always, find a fix
    @objc func filterTapped(_ sender: UIButton) {
        filteredImageView.isHidden = false
        filteredImageView.image = sender.backgroundImage(for: .normal)
    }
    
    // MARk: Set up filters
    
    func addFilters() {
        var x: CGFloat = 5
        var itemCount = 0
        let gapBetweenButtons: CGFloat = 5
        for filterType in filterTypes {
            let filterButton = constructFilterButton(x: x, tag: itemCount, type: itemCount)
            scrollView.addSubview(filterButton)
            itemCount += 1
            x += 70 + gapBetweenButtons
            buttonsArray.append(filterButton)
        }
        scrollView.contentSize = CGSize(width: 70 * CGFloat(itemCount + 2), height: 5)
        //filtersScrollView.contentSize = CGSizeMake(buttonWidth * CGFloat(itemCount+2), yCoord)
    }
    
    func constructFilterButton(x: CGFloat, tag: Int, type: Int) -> UIButton {
        let y: CGFloat = 5
        let width: CGFloat = 70
        let height: CGFloat = 70
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: x, y: y, width: width, height: height)
        button.layer.cornerRadius = 6
        button.clipsToBounds = true
        button.tag = tag
        button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        if let filterImage = createFilterIamge(type: type) {
            button.setBackgroundImage(filterImage, for: .normal) // different from setImage
        } else {
            button.setBackgroundImage(UIImage(named: "god"), for: .normal)
        }
        return button
    }
    
    func createFilterIamge(type: Int) -> UIImage? {
        let ciContext = CIContext(options: nil)
        guard let originalImage = originalImageView.image, let coreImage = CIImage(image: originalImage) else { return nil }
        //UIImage’s CIImage is not nil only if the UIImage is backed by a CIImage already (e.g. it is generated by imageWithCIImage:).
        guard let filter = CIFilter(name: filterTypes[type]) else { return nil }
        filter.setDefaults()
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        //filter.setValue(0.5, forKey: kCIInputIntensityKey) // crashing
        guard let filteredImageData = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return nil }
        //let filteredImage = UIImage(ciImage: filteredImageData) // this is also possible
        guard let filteredImageref = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent) else { return nil }
        let imageForButton = UIImage(cgImage: filteredImageref)
        return imageForButton
    }
    
    func changeButtonImage() {
        var i = 0
        for button in buttonsArray {
            if let filterImage = createFilterIamge(type: i) {
                button.setBackgroundImage(filterImage, for: .normal)
            } else {
                button.setBackgroundImage(UIImage(named: "god"), for: .normal)
            }
            i += 1
        }
    }
    
    // MARK: IBActions

    @IBAction func openPhotoLibrary(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func savePhotoInAlbum(_ sender: UIBarButtonItem) {
        if let filteredImage = filteredImageView.image {
            savePhoto(image: filteredImage)
        }
    }
    
    func savePhoto(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("Photo saved") // what if fails
    }
    
    // MARK: Image picker controller delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            originalImageView.image = selectedImage
            filteredImageView.isHidden = true
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

class ImageView: UIImageView {
    override var image: UIImage? {
        didSet {
            super.image = image
            print("Image Set")
        }
    }
}
