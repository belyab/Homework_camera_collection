//
//  ViewController.swift
//  homework_camera_collection
//
//  Created by ilyas.ikhsanov on 29.04.2022.
//

import UIKit
import MapKit
import Photos
import PhotosUI

class ViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!

    //Dependencies
    private let layout = CustomLayout()
    private var photoCell: [PhotoCell] = []
    private let screenWidth = UIScreen.main.bounds.size.width
    
    var itemWidth: CGFloat {
        return screenWidth * 0.4
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configMapView()
        configCollectionView()
    }
    
    // Private
    private func configMapView() {
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotation.self))
        
        let coordinate = CLLocationCoordinate2D(latitude: 55.799152, longitude: 49.105425)
        let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.delegate = self
        mapView.setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: true)
    }
    
    private func getPhotoFromLibrary() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func getPhotoFromCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func addAnnotation(image: UIImage) {
        let center = self.mapView.centerCoordinate
        let imageAnnotation = CustomAnnotation(coordinate: center)
        imageAnnotation.title = Date().formatted()
        imageAnnotation.image = image
        
        photoCell.append(PhotoCell(image: image, date: Date().formatted(), coordinate: "\(mapView.centerCoordinate.latitude), \(mapView.centerCoordinate.longitude)"))
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.mapView.addAnnotation(imageAnnotation)
        }
    }
    
    private func configCollectionView() {
        collectionView.backgroundColor = UIColor.clear
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.collectionViewLayout = layout
        collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 30.0, bottom: 0.0, right: itemWidth * 2)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 50.0
        layout.minimumInteritemSpacing = 50.0
        layout.itemSize.width = itemWidth
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
        
    }
    
    // MARK: - IBAction
    @IBAction func setPhotoToPlace(_ sender: Any) {
        let alert = UIAlertController()
        alert.addAction(UIAlertAction(title: "Фотопленка", style: .default, handler: { _ in
            self.getPhotoFromLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Камера", style: .default, handler: { _ in
            self.getPhotoFromCamera()
        }))
        alert.addAction(UIAlertAction(title: "ОК", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        addAnnotation(image: image)
    }
}

// MARK: - MKMapViewDelegate

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        if let annotation = annotation as? CustomAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(CustomAnnotation.self), for: annotation)
            
            return annotationView
            
        } else {
            return nil
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
                
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                
                self?.addAnnotation(image: image)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCollectionViewCell {
            cell.setData(photoCell: photoCell[indexPath.item])
            if indexPath.item == 0 {
                transform(cell)
            }
            return cell
        }
        
        return UICollectionViewCell()
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return .init(width: 160, height: 200)
    }
}

// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        if decelerate {
            setupCell()
        }
    }

    private func setupCell() {
        let indexPath = IndexPath(item: layout.currentPage, section: 0)

        if let cell = collectionView.cellForItem(at: indexPath) {
            transform(cell)
        }
    }

    private func transform(_ cell: UICollectionViewCell, isEffect: Bool = true) {
        if !isEffect {
            cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        
        collectionView.visibleCells.forEach { otherCell in
            if let indexPath = collectionView.indexPath(for: otherCell) {
                if indexPath.item != layout.currentPage {
                    UIView.animate(withDuration: 0.2) {
                        otherCell.transform = .identity
                    }
                }
            }
        }
    }
}

