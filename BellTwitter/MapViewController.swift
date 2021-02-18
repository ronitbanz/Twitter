//
//  MapViewController.swift
//  BellTwitterMVP
//
//  Created by Ronit on 2019-01-30.
//  Copyright © 2019 Ronit. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView            : MKMapView!
    @IBOutlet weak var distanceFilterTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var locationKernel       : LocationKernel!
    var tweetViewModels: [TweetViewModel] = []
    var searchFilterValue: Int!
    var annotatedTweets: [TweetAnnotation] = []
    
    /**
    Shared Location Manager model
    */
    var sharedModel: LocationManager!
    
    // Controls
    var controlsEnabled: Bool = true {
        didSet {
            if controlsEnabled {
                print("controls enabled")
                mapView.isUserInteractionEnabled = true
                activityIndicator.stopAnimating()
            } else {
                print("controls disabled")
                mapView.isUserInteractionEnabled = false
                activityIndicator.startAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sharedModel = LocationManager.sharedManager
        sharedModel.startLocationServices()
        mapView.delegate               = self
        distanceFilterTextField.delegate = self
        
        // Appearance
        activityIndicator.hidesWhenStopped = true
        locationKernel = LocationManager.sharedManager.locationKernel
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchTimeline), name: NSNotification.Name(rawValue: "PeriodicCoordinatesSent"), object: nil)
        searchFilterValue = 5
        distanceFilterTextField.text = String(searchFilterValue!)
    }
    
    @objc func fetchTimeline() {
        if (annotatedTweets.count == 0) {
            let span         = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            let region       = MKCoordinateRegion(center: (locationKernel.location?.coordinate)!, span: span)
            mapView.setRegion(region, animated: true)
        }
        APIManager.shared.searchTweets(searchString: "", latitude: (locationKernel.location?.coordinate.latitude)!, longitude: (locationKernel.location?.coordinate.longitude)!, distanceFilter: distanceFilterTextField.text!) { (tweets: [Tweet]?, error: Error?) in
            if let tweets = tweets {
                self.tweetViewModels = tweets.map({return TweetViewModel(tweetModel: $0)}) 
            } else {
                let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        for tweetViewModel in tweetViewModels {
            if (tweetViewModel.hasCoordinates!) {
                self.controlsEnabled = false
                let annotation = TweetAnnotation()
                
                var tweetCoordinates : CLLocationCoordinate2D!
                tweetCoordinates          = CLLocationCoordinate2D(
                    latitude          : tweetViewModel.tweet!.latitude!,
                    longitude         : tweetViewModel.tweet!.longitude!)
                
                annotation.coordinate     = tweetCoordinates!
                if let title = tweetViewModel.tweet?.text
                {
                    annotation.title          = title
                }
                if let subTitle = tweetViewModel.tweet?.id
                {
                    annotation.subtitle       = String(subTitle)
                }
                annotation.tweetViewModel = tweetViewModel
                annotatedTweets.append(annotation)
                self.mapView.addAnnotation(annotation)
            }
        }
        
        //condition to have any more than 100 new tweets annotated
        if (annotatedTweets.count > 100) {
            for _ in 0..<annotatedTweets.count - 100 {
                let annotation = annotatedTweets.removeFirst()
                self.mapView.removeAnnotation(annotation)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToDetailSegue" {
            let tweetAnnotation = sender as! TweetAnnotation
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.tweetViewModel = tweetAnnotation.tweetViewModel
        }
    }
    
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //annotaion color etc
        let annView: MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "tweets")
        if #available(iOS 9.0, *) {
            annView.pinTintColor = MKPinAnnotationView.greenPinColor()
        } else {
            annView.pinColor = .green
        }
        
        annView.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
        annView.animatesDrop = false
        annView.canShowCallout = true
        annView.calloutOffset = CGPoint(x: -5, y: 5)
        return annView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "mapToDetailSegue", sender: self.mapView.selectedAnnotations[0] as? TweetAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        controlsEnabled = true
    }
    
}

extension MapViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        if (textField.text != "") {
            if let number = Int(textField.text!) {
                if (number > 0 && number <= 100) {
                    if (number < searchFilterValue!) {
                        annotatedTweets = []
                        fetchTimeline()
                    }
                    else if (number == searchFilterValue!) {
                        let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("sameValueEntered", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else {
                        annotatedTweets = []
                        fetchTimeline()
                    }
                }
                else {
                    let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("pleaseEnterAValueBetween1To100", comment: ""), preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            else {
                let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("pleaseEnterAValueBetween1To100", comment: ""), preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else {
            let alertController = UIAlertController(title: NSLocalizedString("error", comment: ""), message: NSLocalizedString("pleaseEnterValidNumberBetween1To100", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        return true
    }
    
}
