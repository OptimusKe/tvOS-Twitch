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
import ReactiveCocoa
import WebImage

class StreamCell: UICollectionViewCell {
	static let identifier: String = "cellIdentifierStream"
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var placeholder: UIImageView!
    @IBOutlet weak var gameImageView: UIImageView!
	@IBOutlet weak var streamNameLabel: UILabel!
	@IBOutlet weak var viewersCountLabel: UILabel!
	
	private let defaultTextColor = UIColor.lightGrayColor()
	private let focusedTextColor = UIColor.whiteColor()
	private let defaultStreamFont = UIFont.boldSystemFontOfSize(30)
	private let defaultViewersFont = UIFont.systemFontOfSize(28)
	
	private let viewModel = MutableProperty<StreamViewModel?>(nil)
	
	override func awakeFromNib() {
		super.awakeFromNib()
		imageView.layer.borderWidth = 1.0
		imageView.layer.borderColor = UIColor.clearColor().CGColor
		placeholder.image = placeholder.image?.imageWithRenderingMode(.AlwaysTemplate)
		placeholder.tintColor = UIColor.twitchDarkColor()
		streamNameLabel.textColor = defaultTextColor
		viewersCountLabel.textColor = defaultTextColor
		streamNameLabel.font = defaultStreamFont
		viewersCountLabel.font = defaultViewersFont
		
		let vm = viewModel.producer.ignoreNil()
		streamNameLabel.rac_text <~ vm.flatMap(.Latest) { $0.streamTitle.producer }
		viewersCountLabel.rac_text <~ vm.flatMap(.Latest) { $0.viewersCount.producer }
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = nil
        gameImageView.layer.borderColor = UIColor.clearColor().CGColor
	}
	
	internal func bindViewModel(streamViewModel: StreamViewModel) {
		self.viewModel.value = streamViewModel
		if let url = NSURL(string: streamViewModel.streamImageURL.value) {
			imageView.sd_setImageWithURL(url)
		}
        
        if let gameName = streamViewModel.gameNameString() {
            
            let gameImageUrl = "http://static-cdn.jtvnw.net/ttv-boxart/" + gameName + "-136x190.jpg"
            let gameImageUrlWithEncoding:String = gameImageUrl.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
            let url = NSURL(string: gameImageUrlWithEncoding)
            self.gameImageView.sd_setImageWithURL(url, completed: { (image: UIImage?, error: NSError?, cacheType: SDImageCacheType!, imageURL: NSURL?) -> Void in
                
                if let wSelf: StreamCell = self {
                    wSelf.gameImageView.layer.borderWidth = 3.0
                    wSelf.gameImageView.layer.borderColor = UIColor.whiteColor().CGColor
                }
            })
        }
        
	}
	
	override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		let color = self.focused ? focusedTextColor : defaultTextColor
		let borderColor = self.focused ? UIColor.whiteColor().CGColor : UIColor.clearColor().CGColor
		if focused {
			applyMotionEffectForX(10, y: 10)
		} else {
			removeMotionEffects()
		}
		coordinator.addCoordinatedAnimations({
			[weak self] in
			self?.viewersCountLabel.textColor = color
			self?.streamNameLabel.textColor = color
			self?.imageView.layer.borderColor = borderColor
			}, completion: nil)
	}
}
