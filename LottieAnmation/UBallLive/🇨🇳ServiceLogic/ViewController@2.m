//
//  ViewController@2.m
//  U球直播
//
//  Created by Jobs on 2020/10/9.
//

#import "ViewController@2.h"

#import "VerticalListCell.h"
#import "VerticalSectionHeaderView.h"
#import "VerticalSectionCategoryHeaderView.h"
#import "VerticalListCollectionView.h"

#import "VerticalListSectionModel.h"

static const CGFloat VerticalListCategoryViewHeight = 60;   //悬浮categoryView的高度
static const NSUInteger VerticalListPinSectionIndex = 1;    //悬浮固定section的index

@interface ViewController_2 ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
JXCategoryViewDelegate
>

@property(nonatomic,strong)VerticalListCollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray <VerticalListSectionModel *> *dataSource;
@property(nonatomic,strong)JXCategoryTitleView *pinCategoryView;
@property(nonatomic,strong)VerticalSectionCategoryHeaderView *sectionCategoryHeaderView;
@property(nonatomic,strong)NSMutableArray <UICollectionViewLayoutAttributes *> *sectionHeaderAttributes;
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@property(nonatomic,strong)JXCategoryIndicatorLineView *lineView;

@property(nonatomic,strong)NSMutableArray <NSString *> *headerTitles;
@property(nonatomic,strong)NSMutableArray <NSString *> *imageNames;
@property(nonatomic,strong)NSMutableArray <NSIndexPath *>*indexPathMutArr;

@end

@implementation ViewController_2


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kWhiteColor;
    [self.headerTitles enumerateObjectsUsingBlock:^(NSString *title,
                                                    NSUInteger idx,
                                                    BOOL * _Nonnull stop) {
        VerticalListSectionModel *sectionModel = VerticalListSectionModel.new;
        sectionModel.sectionTitle = title;
        NSUInteger randomCount = arc4random() % 10 + 5;
        NSMutableArray *cellModels = [NSMutableArray array];
        for (int i = 0; i < randomCount; i ++) {
            VerticalListCellModel *cellModel = VerticalListCellModel.new;
            cellModel.imageName = self.imageNames[idx];
            cellModel.itemName = title;
            [cellModels addObject:cellModel];
        }
        sectionModel.cellModels = cellModels;
        [self.dataSource addObject:sectionModel];
    }];

    self.collectionView.alpha = 1;
    self.pinCategoryView.alpha = 1;
}

- (void)updateSectionHeaderAttributes {
    if (!self.sectionHeaderAttributes.count) {
        //获取到所有的sectionHeaderAtrributes，用于后续的点击，滚动到指定contentOffset.y使用
        UICollectionViewLayoutAttributes *lastHeaderAttri = nil;
        for (int i = 0; i < self.headerTitles.count; i++) {
            UICollectionViewLayoutAttributes *attri = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                               atIndexPath:[NSIndexPath indexPathForItem:0
                                                                                                                                                               inSection:i]];
            if (attri) {
                [self.sectionHeaderAttributes addObject:attri];
            }
            if (i == self.headerTitles.count - 1) {
                lastHeaderAttri = attri;
            }
        }
        if (self.sectionHeaderAttributes.count == 0) {
            return;
        }

        //如果最后一个section条目太少了，会导致滚动最底部，但是却不能触发categoryView选中最后一个item。而且点击最后一个滚动的contentOffset.y也不好弄。所以添加contentInset，让最后一个section滚到最下面能显示完整个屏幕。
        UICollectionViewLayoutAttributes *lastCellAttri = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource[self.headerTitles.count - 1].cellModels.count - 1
                                                                                                                                                           inSection:self.headerTitles.count - 1]];
        CGFloat lastSectionHeight = CGRectGetMaxY(lastCellAttri.frame) - CGRectGetMinY(lastHeaderAttri.frame);
        CGFloat value = (self.view.bounds.size.height - VerticalListCategoryViewHeight) - lastSectionHeight;
        if (value > 0) {
            self.collectionView.contentInset = UIEdgeInsetsMake(0,
                                                                0,
                                                                value,
                                                                0);
        }
    }
}
#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                                   cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    VerticalListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    VerticalListSectionModel *sectionModel = self.dataSource[indexPath.section];
    VerticalListCellModel *cellModel = sectionModel.cellModels[indexPath.row];
    cell.itemImageView.image = [UIImage imageNamed:cellModel.imageName];
    cell.titleLabel.text = cellModel.itemName;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (self.indexPathMutArr.count) {
        for (NSIndexPath *indexPath in self.indexPathMutArr) {
            if (section == indexPath.section) {
                return 0;
            }
        }
    }return self.dataSource[section].cellModels.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == VerticalListPinSectionIndex) {
            VerticalSectionCategoryHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                               withReuseIdentifier:@"categoryHeader"
                                                                                                      forIndexPath:indexPath];
            self.sectionCategoryHeaderView = headerView;
            headerView.indexPath = indexPath;
            if (!self.pinCategoryView.superview) {
                //首次使用VerticalSectionCategoryHeaderView的时候，把pinCategoryView添加到它上面。
                [headerView addSubview:self.pinCategoryView];
            }
            return headerView;
        }else {
            VerticalSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                       withReuseIdentifier:@"header"
                                                                                              forIndexPath:indexPath];
            headerView.indexPath = indexPath;
            [headerView richElementsInCellWithModel:self.dataSource[indexPath.section]];
            @weakify(self)
            [headerView actionBlockCollectionReusableView:^(NSIndexPath *data) {
                @strongify(self)
                if (self.indexPathMutArr.count) {//已经点击过
                    [self.indexPathMutArr addObject:data];
                    for (NSIndexPath *indexPath in self.indexPathMutArr) {
                        if (indexPath.section == data.section &&
                            indexPath.row == data.row) {//存在同一个
                            [self.indexPathMutArr removeObject:data];//同一个就删除
                            if (!self.indexPathMutArr.count) {
                                break;
                            }
                        }
                    }
                }else{//第一次点击
                    [self.indexPathMutArr addObject:data];
                }
                
                [self.collectionView reloadData];
                NSLog(@"");
            }];
            return headerView;
        }
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                              withReuseIdentifier:@"other"
                                                     forIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.sectionHeaderAttributes.count) {
        UICollectionViewLayoutAttributes *attri = self.sectionHeaderAttributes[VerticalListPinSectionIndex];
        if (scrollView.contentOffset.y >= attri.frame.origin.y) {
            //当滚动的contentOffset.y大于了指定sectionHeader的y值，且还没有被添加到self.view上的时候，就需要切换superView
            if (self.pinCategoryView.superview != self.view) {
                [self.view addSubview:self.pinCategoryView];
            }
        }else if (self.pinCategoryView.superview != self.sectionCategoryHeaderView) {
            //当滚动的contentOffset.y小于了指定sectionHeader的y值，且还没有被添加到sectionCategoryHeaderView上的时候，就需要切换superView
            [self.sectionCategoryHeaderView addSubview:self.pinCategoryView];
        }
        if (self.pinCategoryView.selectedIndex != 0 && scrollView.contentOffset.y == 0) {
            //点击了状态栏滚动到顶部时的处理
            [self.pinCategoryView selectItemAtIndex:0];
        }
        if (!(scrollView.isTracking || scrollView.isDecelerating)) {
            //不是用户滚动的，比如setContentOffset等方法，引起的滚动不需要处理。
            return;
        }
        //用户滚动的才处理
        //获取categoryView下面一点的所有布局信息，用于知道，当前最上方是显示的哪个section
        CGRect topRect = CGRectMake(0,
                                    scrollView.contentOffset.y + VerticalListCategoryViewHeight + 1,
                                    self.view.bounds.size.width,
                                    1);
        UICollectionViewLayoutAttributes *topAttributes = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:topRect].firstObject;
        NSUInteger topSection = topAttributes.indexPath.section;
        if (topAttributes != nil && topSection >= VerticalListPinSectionIndex) {
            if (self.pinCategoryView.selectedIndex != topSection - VerticalListPinSectionIndex) {
                //不相同才切换
                [self.pinCategoryView selectItemAtIndex:topSection - VerticalListPinSectionIndex];
            }
        }
    }
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == VerticalListPinSectionIndex) {
        //categoryView所在的headerView要高一些
        return CGSizeMake(self.view.bounds.size.width, VerticalListCategoryViewHeight);
    }
    return CGSizeMake(self.view.bounds.size.width, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return (self.view.bounds.size.width - 100 * 3) / 4;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    CGFloat margin = (self.view.bounds.size.width - 100 * 3) / 4;
    return UIEdgeInsetsMake(0,
                            margin,
                            0,
                            margin);
}
#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView
didClickSelectedItemAtIndex:(NSInteger)index {
    //这里关心点击选中的回调！！！
    if (self.sectionHeaderAttributes.count) {
        UICollectionViewLayoutAttributes *targetAttri = self.sectionHeaderAttributes[index + VerticalListPinSectionIndex];
        if (index == 0) {
            //选中了第一个，特殊处理一下，滚动到sectionHeaer的最上面
            [self.collectionView setContentOffset:CGPointMake(0, targetAttri.frame.origin.y) animated:YES];
        }else {
            //不是第一个，需要滚动到categoryView下面
            [self.collectionView setContentOffset:CGPointMake(0, targetAttri.frame.origin.y - VerticalListCategoryViewHeight) animated:YES];
        }
    }
}
#pragma mark —— lazyLoad
-(UICollectionViewFlowLayout *)layout{
    if (!_layout) {
        _layout = UICollectionViewFlowLayout.new;
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }return _layout;
}

-(VerticalListCollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[VerticalListCollectionView alloc] initWithFrame:CGRectZero
                                                       collectionViewLayout:self.layout];
        @weakify(self)
        _collectionView.layoutSubviewsCallback = ^{
            @strongify(self)
            [self updateSectionHeaderAttributes];
        };
        
        _collectionView.backgroundColor = RGBCOLOR(231, 243, 252);
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:VerticalListCell.class forCellWithReuseIdentifier:@"cell"];
        [_collectionView registerClass:VerticalSectionHeaderView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"header"];
        [_collectionView registerClass:VerticalSectionCategoryHeaderView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"categoryHeader"];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }return _collectionView;
}

-(JXCategoryIndicatorLineView *)lineView{
    if (!_lineView) {
        _lineView = JXCategoryIndicatorLineView.new;
        _lineView.verticalMargin = 15;
    }return _lineView;
}

-(JXCategoryTitleView *)pinCategoryView{
    if (!_pinCategoryView) {
        //创建pinCategoryView，但是不要 addSubview
        _pinCategoryView = JXCategoryTitleView.new;
        self.pinCategoryView.backgroundColor = RGBCOLOR(231, 243, 252);
        self.pinCategoryView.frame = CGRectMake(0, 0, SCREEN_WIDTH, VerticalListCategoryViewHeight);
        self.pinCategoryView.titles = @[@"超级大IP", @"热门HOT", @"周边衍生", @"影视综", @"游戏集锦", @"搞笑百事"];
        self.pinCategoryView.indicators = @[self.lineView];
        self.pinCategoryView.delegate = self;
    }return _pinCategoryView;
}

-(NSMutableArray<NSString *> *)headerTitles{
    if (!_headerTitles) {
        _headerTitles = NSMutableArray.array;
        [_headerTitles addObject:@"我的频道"];
        [_headerTitles addObject:@"超级大IP"];
        [_headerTitles addObject:@"热门HOT"];
        [_headerTitles addObject:@"周边衍生"];
        [_headerTitles addObject:@"影视综"];
        [_headerTitles addObject:@"游戏集锦"];
        [_headerTitles addObject:@"搞笑百事"];
    }return _headerTitles;
}

-(NSMutableArray<NSString *> *)imageNames{
    if (!_imageNames) {
        _imageNames = NSMutableArray.array;
        [_imageNames addObject:@"boat"];
        [_imageNames addObject:@"crab"];
        [_imageNames addObject:@"lobster"];
        [_imageNames addObject:@"apple"];
        [_imageNames addObject:@"carrot"];
        [_imageNames addObject:@"grape"];
        [_imageNames addObject:@"watermelon"];
    }return _imageNames;
}

-(NSMutableArray<VerticalListSectionModel *> *)dataSource{
    if (!_dataSource) {
        _dataSource = NSMutableArray.array;
    }return _dataSource;
}

-(NSMutableArray<UICollectionViewLayoutAttributes *> *)sectionHeaderAttributes{
    if (!_sectionHeaderAttributes) {
        _sectionHeaderAttributes = NSMutableArray.array;
    }return _sectionHeaderAttributes;
}

-(NSMutableArray<NSIndexPath *> *)indexPathMutArr{
    if (!_indexPathMutArr) {
        _indexPathMutArr = NSMutableArray.array;
    }return _indexPathMutArr;
}

@end
