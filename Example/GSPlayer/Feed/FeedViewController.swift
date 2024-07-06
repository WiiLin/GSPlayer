//
//  FeedViewController.swift
//  GSPlayer_Example
//
//  Created by Gesen on 2020/5/17.
//  Copyright © 2020 Gesen. All rights reserved.
//

import GSPlayer

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var items: [URL] = [
        URL(string: "https://d6h9y78ya6qu5.cloudfront.net/post-1412965818-1716806396276/06d80f86-46b6-4ab4-bd6d-eadf77ed994d/file_0.mp4")!,
        URL(string: "https://d6h9y78ya6qu5.cloudfront.net/post-5352192119-1716828512963/43bfd68b-5301-45c4-ae26-23991f40b835/file_0.mp4")!,
//        URL(string: "http://vfx.mtime.cn/Video/2019/06/29/mp4/190629004821240734.mp4")!,
//        URL(string: "http://vfx.mtime.cn/Video/2019/06/27/mp4/190627231412433967.mp4")!,
//        URL(string: "http://vfx.mtime.cn/Video/2019/06/25/mp4/190625091024931282.mp4")!,
//        URL(string: "http://vfx.mtime.cn/Video/2019/06/16/mp4/190616155507259516.mp4")!,
//        URL(string: "http://vfx.mtime.cn/Video/2019/06/15/mp4/190615103827358781.mp4")!,
//        URL(string: "http://vfx.mtime.cn/Video/2019/06/05/mp4/190605101703931259.mp4")!,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "FeedCell", bundle: nil), forCellReuseIdentifier: "Cell")

        guard let first = items.first else {return }
        VideoPreloadManager.shared.didFinish = { [weak self] url, error in
            guard error == nil else { return }
            self?.startTableView()
            VideoPreloadManager.shared.didFinish = nil

        }
        VideoPreloadManager.shared.startPreload(urls: [first])

    }

    func startTableView() {
        print("feed startTableView")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        
        print("cellForRowAt \(indexPath.row)")
        cell.set(url: items[indexPath.row])
        cell.play()
        checkPreload()
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("didEndDisplaying \(indexPath.row)")
        if let cell = cell as? FeedCell, let url = cell.url {
            cell.pause()
            VideoPreloadManager.shared.pause(url: url)
            VideoLoadManager.shared.cancel(url: url)
        }
    }

    
    func checkPreload() {
        guard let lastRow = tableView.indexPathsForVisibleRows?.last?.row else { return }
        
        let urls = items
            .suffix(from: min(lastRow + 1, items.count))
            .prefix(1)
        
        VideoPreloadManager.shared.startPreload(urls: Array(urls))
    }
}
