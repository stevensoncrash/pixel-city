//
//  MapVC.swift
//  pixal-city
//
//  Created by Stephen Reyes on 6/28/18.
//  Copyright © 2018 Stephen Reyes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    //outlets
    
   

    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var screenSize = UIScreen.main.bounds
    
    var spinner : UIActivityIndicatorView?
    var progressLbl : UILabel?
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        
        
        pullUpView.addSubview(collectionView!)
        
        registerForPreviewing(with: self, sourceView: collectionView)
        
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    func addSwipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp(){
        pullUpHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
             self.view.layoutIfNeeded()
        }
    }
    @objc func animateViewDown(){
        cancellAllSession()
        pullUpHeightConstraint.constant = 0
        UIView.animate(withDuration:  0.3) {
            self.view.layoutIfNeeded()
        }
    }
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)

    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120 , y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next" , size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl() {
        if progressLbl != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    //actions
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
 
}

extension MapVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
    }
    @objc func dropPin(sender: UITapGestureRecognizer){
        removePin()
        removeSpinner()
        removeProgressLbl()
        cancellAllSession()
        
        imageUrlArray = []
        imageArray = []
  
        collectionView?.reloadData()
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        let cooridinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0 , regionRadius * 2.0)
        mapView.setRegion(cooridinateRegion, animated: true)
        
        retrieveURLs(forAnnotiation: annotation) { (finished) in
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    func removePin(){
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveURLs(forAnnotiation annotation: DroppablePin, handler: @escaping(_ status: Bool)-> ()){
        
        Alamofire.request(flickrURL(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else {return}
            let photosDic = json["photos"] as! Dictionary<String, AnyObject>
            let photosDicArray = photosDic["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDicArray {
                let postUrl = "https:\\farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_k_d.jpeg"
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
        
    func retrieveImages(handler: @escaping(_ status: Bool) -> ()) {
    
            for url in imageUrlArray {
                Alamofire.request(url).responseImage { (response) in
                    guard let image = response.result.value else {return}
                    self.imageArray.append(image)
                    self.progressLbl?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                    
                    if self.imageArray.count == self.imageUrlArray.count {
                        handler(true)
                    }
                }
            }
        }
    
    func cancellAllSession(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, upLoadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
}
extension MapVC: CLLocationManagerDelegate{
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return the number of items in the array
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()}
            let imageFromIndex = imageArray[indexPath.row]
            let imageView = UIImageView(image: imageFromIndex)
            cell.addSubview(imageView)
            return cell
        }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
}
// 3d touch requirments

extension MapVC: UIViewControllerPreviewingDelegate{
    
    //pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell =  collectionView?.cellForItem(at: indexPath) else { return nil}
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") as? PopVC else {return nil}
        
        popVC.initData(forImage: imageArray[indexPath.row])
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    
    //peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}















}
