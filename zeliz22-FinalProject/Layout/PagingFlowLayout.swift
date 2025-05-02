import UIKit

class PagingFlowLayout: UICollectionViewFlowLayout {
    
    private let sideItemScale: CGFloat = 0.8  // Scale of side items
    private let sideItemAlpha: CGFloat = 0.6  // Transparency for side items
    private let spacing: CGFloat = 10        // Spacing between items
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let collectionViewWidth = collectionView.bounds.width
        let itemWidth = collectionViewWidth * 0.7  // Center item is 70% of screen width
        let itemHeight = collectionView.bounds.height * 0.9 // Adjust height if needed
        
        itemSize = CGSize(width: itemWidth, height: itemHeight)
        minimumLineSpacing = spacing
        scrollDirection = .horizontal
        
        let insetX = (collectionViewWidth - itemWidth) / 2  // Ensure centering
        collectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        collectionView.decelerationRate = .fast
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let visibleRect = CGRect(origin: proposedContentOffset, size: collectionView.bounds.size)
        let centerX = visibleRect.midX
        
        let layoutAttributes = layoutAttributesForElements(in: visibleRect)
        let closestAttribute = layoutAttributes?.min(by: {
            abs($0.center.x - centerX) < abs($1.center.x - centerX)
        })
        
        return CGPoint(x: (closestAttribute?.center.x ?? proposedContentOffset.x) - collectionView.bounds.width / 2, y: proposedContentOffset.y)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        
        let attributes = super.layoutAttributesForElements(in: rect)
        attributes?.forEach { attribute in
            let distance = abs(attribute.center.x - centerX)
            let scale = max(sideItemScale, 1 - distance / collectionView.bounds.width)
            let alpha = max(sideItemAlpha, 1 - distance / collectionView.bounds.width)
            
            attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
            attribute.alpha = alpha
        }
        
        return attributes
    }
}
