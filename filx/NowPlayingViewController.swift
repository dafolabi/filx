//
//  NowPlayingViewController.swift
//  filx
//
//  Created by Daniel Afolabi on 6/21/17.
//  Copyright © 2017 Daniel Afolabi. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movies: [[String: Any]] = []
    var refreshControl: UIRefreshControl!
    
    var alertController: UIAlertController!
    
    override func viewDidLoad() {
        // Start the activity indicator
        activityIndicator.startAnimating()
        
        super.viewDidLoad()
        
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
        tableView.insertSubview(refreshControl, at: topOfPage)
        tableView.dataSource = self
        tableView.delegate = self
        
        
        fetchMovies()
    }
    
    func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        fetchMovies()
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
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            // Stop the activity indicator
            // Hides automatically if "Hides When Stopped" is enabled
           self.activityIndicator.stopAnimating()
        }
        task.resume()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString =  "https://image.tmdb.org/t/p/w500"
        
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.posterImageView.af_setImage(withURL: posterURL)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
        let movie = movies[indexPath.row]
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
