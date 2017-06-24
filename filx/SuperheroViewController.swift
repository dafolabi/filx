//
//  SuperheroViewController.swift
//  filx
//
//  Created by Daniel Afolabi on 6/23/17.
//  Copyright © 2017 Daniel Afolabi. All rights reserved.
//

import UIKit

class SuperheroViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    
    var alertController: UIAlertController!

    override func viewDidLoad() {
        // Start the activity indicator
        activityIndicator.startAnimating()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        alertController = UIAlertController(title: "Cannot get movies", message: "The Internet connection appears to be offline", preferredStyle: .alert)
        // create a cancel action
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .cancel) { (action) in
            self.fetchMovies()
        }
        // add the cancel action to the alertController
        alertController.addAction(tryAgainAction)
        
        let topOfPage = 0
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        collectionView.insertSubview(refreshControl, at: topOfPage)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
        let cellsPerLine: CGFloat = 3;
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = collectionView.frame.size.width / cellsPerLine - interItemSpacingTotal / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
        
        fetchMovies()
    }

    func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchMovies()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        let movie = movies[indexPath.item]
        if let posterPathString = movie["poster_path"] as? String {
        let baseURLString =  "https://image.tmdb.org/t/p/w500"
        let posterURL = URL(string: baseURLString + posterPathString)!
            cell.posterImageView.af_setImage(withURL: posterURL)
        }
        return cell
    }
    
    func fetchMovies() {
        // Do any additional setup after loading the view.
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, reponse, error) in
            // This will run when the network request returns
            if let error = error {
                self.present(self.alertController, animated: true)
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.collectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
            // Stop the activity indicator
            // Hides automatically if "Hides When Stopped" is enabled
            self.activityIndicator.stopAnimating()

        }
        task.resume()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell) {
            let movie = movies[indexPath.item]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
        
    }

}
