// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import SwiftyJSON
import GooglePlaces
import GoogleMaps
import CoreLocation
import Firebase
import FirebaseStorage
import FirebaseAuth
import AVFoundation


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let speak = AVSpeechSynthesizer()
    
    var descriptionText = String()
    var sampleArray = [String]()
    var gmsPlaces: GMSPlace?
    
    var isDetected = false
    
    let reference = FIRDatabase.database().reference()
    let storage = FIRStorage.storage().reference()
    let currentUser = FIRAuth.auth()?.currentUser
    var locationNameFound = String()
    let imagePicker = UIImagePickerController()
    let session = URLSession.shared
    
    
    @IBOutlet weak var nearbyButton: UIBarButtonItem!
    
    @IBOutlet weak var descriptionBox: UITextView!
    @IBOutlet weak var more: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var labelResults: UITextView!
    @IBOutlet weak var faceResults: UITextView!
    @IBOutlet weak var camera: UIButton!
    @IBOutlet weak var libraryProperty: UIButton!
    
    var googleAPIKey = "AIzaSyBOVezq-rZKV4loLS6XLbhE2RUb0Fify9c"
    
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: CameraAction
    
    @IBAction func cameraAction(_ sender: UIButton) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //design round buttons
        camera.layer.cornerRadius = 5
        camera.layer.borderWidth = 2
        libraryProperty.layer.cornerRadius = 5
        libraryProperty.layer.borderWidth = 2
        
        
        
        nearbyButton.isEnabled = false
        
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        labelResults.isHidden = true
        faceResults.isHidden = true
        descriptionBox.isHidden = true
        spinner.hidesWhenStopped = true
        
        //instantiate more bar button to reveal controller
        more.target = self.revealViewController()
        more.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //code for panning screen to more options.
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 44/255, green: 188/255, blue: 211/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        
    }
}


/// Image processing

extension ViewController {
    
    func analyzeResults(_ dataToParse: Data) {
        
        // Update UI on the main thread
        DispatchQueue.main.async(execute: {
            
            
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            
            self.spinner.stopAnimating()
            self.imageView.isHidden = false
            self.labelResults.isHidden = false
            self.descriptionBox.isHidden = false
            self.faceResults.isHidden = false
            self.faceResults.text = ""
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                self.labelResults.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // Parse the response
                print(json)
                let responses: JSON = json["responses"][0]
                
                // Get face annotations
                let faceAnnotations: JSON = responses["faceAnnotations"]
                if faceAnnotations != nil {
                    let emotions: Array<String> = ["joy", "sorrow", "surprise", "anger"]
                    
                    let numPeopleDetected:Int = faceAnnotations.count
                    
//                    self.faceResults.text = "People detected: \(numPeopleDetected)\n\nEmotions detected:\n"
                    if numPeopleDetected == 1{
                        self.faceResults.text = "\(numPeopleDetected) person is feeling "
                    }else if (numPeopleDetected > 1){
                        self.faceResults.text = "\(numPeopleDetected) people are feeling "
                    }
                    
                    
                    var emotionTotals: [String: Double] = ["sorrow": 0, "joy": 0, "surprise": 0, "anger": 0]
                    var emotionLikelihoods: [String: Double] = ["VERY_LIKELY": 0.9, "LIKELY": 0.75, "POSSIBLE": 0.5, "UNLIKELY":0.25, "VERY_UNLIKELY": 0.0]
                    
                    for index in 0..<numPeopleDetected {
                        let personData:JSON = faceAnnotations[index]
                        
                        // Sum all the detected emotions
                        for emotion in emotions {
                            let lookup = emotion + "Likelihood"
                            let result:String = personData[lookup].stringValue
                            emotionTotals[emotion]! += emotionLikelihoods[result]!
                        }
                    }
                    // Get emotion likelihood as a % and display in UI
                    for (emotion, total) in emotionTotals {
                        let likelihood:Double = total / Double(numPeopleDetected)
                        let percent: Int = Int(round(likelihood * 100))
                        //
                        if (percent > 0){
                            switch(emotion){
                            case "sorrow":
                                self.faceResults.text! += "sad"
                            case "joy":
                                self.faceResults.text! += "joyful"
                            case "surprise":
                                self.faceResults.text! += "surprised"
                            case "anger":
                                self.faceResults.text! += "furious"
                            default:
                                print("nothing")
                            }
                        }
                        //
//                        self.faceResults.text! += "\(emotion): \(percent)%\n"
                    }
                    
                } else {
                    self.faceResults.text = "No faces found"
                }
                
                // Get label annotations
                let labelAnnotations: JSON = responses["labelAnnotations"]
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    var labelResultsText:String = "Labels found: "
                    for index in 0..<numLabels {
                        let label = labelAnnotations[index]["description"].stringValue
                        labels.append(label)
                    }
                    for label in labels {
                        // if it's not the last item add a comma
                        if labels[labels.count - 1] != label {
                            labelResultsText += "\(label), "
                        } else {
                            labelResultsText += "\(label)"
                        }
                    }
                    self.labelResults.text = labelResultsText
                } else {
                    self.labelResults.text = "No labels found"
                }
                
                //Get landmark annotations
                let landmarkAnnotations: JSON = responses["landmarkAnnotations"]
                let numberLabels: Int = landmarkAnnotations.count
                var landmarks: Array<String> = []
                
                //myCode
                
                
                if numberLabels > 0 {
                    var landmarkResultText: String = "Landmark found: "
                    
                    for index in 0..<numberLabels {
                        let label = landmarkAnnotations[index]["description"].stringValue
                        let latitude = landmarkAnnotations[index]["locations"].arrayValue.map({$0["latLng"]["latitude"]})
                        let longitude = landmarkAnnotations[index]["locations"].arrayValue.map({$0["latLng"]["longitude"]})
                        
                        let latFloat = String(describing: latitude[0])
                        print("latFloat: \(latFloat)")
                        let lonFloat = String(describing: longitude[0])
                        LocationDetails.longitude = lonFloat
                        LocationDetails.latitude = latFloat
                        
                        landmarks.append(label)
                    }
                    
                    for landmark in landmarks {
                        // if it's not the last item add a comma
                        if landmarks[landmarks.count - 1] != landmark {
                            self.locationNameFound = landmark
                            self.getPlaceDetails(locationName: landmark)
                            landmarkResultText += "\(landmark), "
                        } else {
                            self.getPlaceDetails(locationName: landmark)
                            landmarkResultText += "\(landmark)"
                            self.locationNameFound = landmark
                        }
                    }
                    self.faceResults.text! += " at \(self.locationNameFound)"
                    self.labelResults.text = landmarkResultText
                    print("Description Text: \(self.descriptionText)")
                    print("Array Count: \(self.sampleArray.count)")
                    //self.descriptionBox.text = self.descriptionText
                    self.isDetected = true
                    self.nearbyButton.isEnabled = true
                    
                    self.saveDataToFirebase()
                } else {
                    self.labelResults.text = "No landmarks found"
                    self.descriptionBox.text = "No Quick facts"
                }
                //end of landmark detection
                let speakText = AVSpeechUtterance(string: self.labelResults.text)
                self.speak.speak(speakText)
            }
        })
        
    }
    
    func saveDataToFirebase(){
        let imageName = NSUUID().uuidString
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        let filePath = "\(FIRAuth.auth()!.currentUser!.uid)/\("\(imageName).png")"
        
        storage.child(filePath).put(UIImageJPEGRepresentation(imageView.image!, 0.8)!, metadata: metaData) { (metaData, error) in
            if error == nil {
                let downloadURL = metaData!.downloadURL()!.absoluteString
                self.reference.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("history").childByAutoId().updateChildValues(["picture": downloadURL, "locationName": self.locationNameFound])
                print("Uploaded")
            }else{
                print("Error Uploading")
            }
            
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.isHidden = false // You could optionally display the image here by setting 
            imageView.image = pickedImage
            spinner.startAnimating()
            faceResults.isHidden = true
            labelResults.isHidden = true
            self.descriptionBox.isHidden = true
            
            
            // Base64 encode the image and create the request
            let binaryImageData = base64EncodeImage(pickedImage)
            createRequest(with: binaryImageData)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func printDescription(value: String){
        //print("StringValue: \(value)")
        var newString : String = "Quick Facts: "
        newString += value
        DispatchQueue.main.async {
            self.descriptionBox.text = newString
        }
    }
    
    func getPlaceDetails(locationName: String){
        var sampleDescription = String()
        //self.descriptionText = " "
        self.descriptionBox.text = " "
        let appId = "b6899610"
        let appKey = "7db725df2ac8683436b5aaa5788d452a"
        let language = "en"
        let newLocationName = locationName.replacingOccurrences(of: " ", with: "_")
        let word = newLocationName
        let region = "us"
        let word_id = word.lowercased() //word id is case sensitive and lowercase is required
        let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(word_id)/regions=\(region)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        
        
        
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response,
                let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                //print(response)
                //print(jsonData)
                //
                
                if let json = jsonData as? [String: Any]{
                    if let results = json["results"] as? [[String: Any]]{
                        //print(results)
                        if let lexicalEntries = results[0]["lexicalEntries"] as? [[String: Any]]{
                            if let entries = lexicalEntries[0]["entries"] as? [[String: Any]]{
                                if let senses = entries[0]["senses"] as? [[String: Any]]{
                                    if let definitions = senses[0]["definitions"] as? [String]{
                                        
                                        if let locationDescription = definitions[0] as? String{
                                            //print(locationDescription)
                                            self.printDescription(value: locationDescription)
                                        }
                                        
                                        
                                        
                                            //self.descriptionText = locationDescription
                                        
                                        
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    
                }//
                
               
             //print("1. \(sampleDescription)")
            } else {
                print(error?.localizedDescription)
                print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
            }
        }).resume()
        
    
    }
    
}


/// Networking

extension ViewController {
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(with imageBase64: String) {
        // Create our request URL
        
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 10
                    ],
                    [
                        "type": "LANDMARK_DETECTION",
                        "maxResults": 3
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            self.analyzeResults(data)
        }
        
        task.resume()
    }
}


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
