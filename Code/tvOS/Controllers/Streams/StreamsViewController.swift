// Copyright (c) 2015 Benoit Layer
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class StreamsViewController: UIViewController {

	let streamCellWidth: CGFloat = 308.0
	let horizontalSpacing: CGFloat = 50.0
	let verticalSpacing: CGFloat = 100.0
	
	var onStreamSelected: (Stream -> ())?
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var noItemsLabel: UILabel!
	
	var streamListDataSource: StreamsDataSource? {
		didSet {
			collectionView.dataSource = streamListDataSource
			streamListDataSource?.streamListViewModel.data.producer.startWithNext {
				[weak self] data in
				self?.collectionView.reloadData()
				self?.noItemsLabel.hidden = data.count > 0
			}
			streamListDataSource?.loadMore()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.twitchDarkColor()
		
		noItemsLabel.text = NSLocalizedString("No game selected yet. Pick a game in the upper list.", comment: "")
		noItemsLabel.font = UIFont.systemFontOfSize(42)
		noItemsLabel.textColor = UIColor.whiteColor()
		
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .Vertical
		layout.itemSize = CGSize(width: streamCellWidth, height: streamCellWidth/Constants.streamImageRatio)
		layout.sectionInset = UIEdgeInsets(top: 60, left: 90, bottom: 60, right: 90)
		layout.minimumInteritemSpacing = horizontalSpacing
		layout.minimumLineSpacing = verticalSpacing
		
		collectionView.registerNib(UINib(nibName: "StreamCell", bundle: nil), forCellWithReuseIdentifier: StreamCell.identifier)
		collectionView.collectionViewLayout = layout
		collectionView.delegate = self
	}
}

extension StreamsViewController: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		guard let streamListDataSource = streamListDataSource else { return }
		onStreamSelected?(streamListDataSource.streamListViewModel.data.value[indexPath.row])
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		guard let streamListViewModel = streamListDataSource?.streamListViewModel else { return }
		let contentOffsetY = scrollView.contentOffset.y + scrollView.bounds.size.height
		let wholeHeight = scrollView.contentSize.height
		
		let remainingDistanceToBottom = wholeHeight - contentOffsetY
		
		if remainingDistanceToBottom <= 200 && streamListViewModel.loadingState.value == .Available {
			streamListViewModel.loadMore()
		}
	}
}


