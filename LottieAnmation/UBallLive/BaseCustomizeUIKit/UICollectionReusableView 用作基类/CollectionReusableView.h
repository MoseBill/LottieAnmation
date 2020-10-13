//
//  CollectionReusableView.h
//  UBallLive
//
//  Created by Jobs on 2020/10/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    SectionHeader,
    SectionFooter,
} UICollectionElementKind;

@interface CollectionReusableView : UICollectionReusableView

@property(nonatomic,strong)NSIndexPath *indexPath;
@property(nonatomic,copy)MKDataBlock collectionReusableViewBlock;
@property(nonatomic,assign)BOOL selected;

-(void)actionBlockCollectionReusableView:(MKDataBlock)collectionReusableViewBlock;

@end

NS_ASSUME_NONNULL_END
