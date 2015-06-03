//
//  ViewController.m
//  ScrollableTab
//
//  Created by Pranay on 11/03/15.
//  Copyright (c) 2015 mobitronics. All rights reserved.
//

#import "ViewController.h"

//CONSTANTS
#define kMAXCOUNT     9

@interface ViewController ()<UIScrollViewDelegate> {
  //Outelets
  __weak IBOutlet UIScrollView *verticalScrollView;
  __weak IBOutlet UIScrollView *scrollableTabScrollView;
  
  //Variables
  CGFloat scrollTabItemWidth;
  NSMutableArray *colorArr;
}

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //Prepare color array
  colorArr = [NSMutableArray array];
  for (int iCount=0; iCount<kMAXCOUNT; iCount++) {
    [colorArr addObject:[self prepareRandomColor]];
  }
  
  //Set scrollview delegates
  [verticalScrollView setDelegate:self];
  [scrollableTabScrollView setDelegate:self];
  [scrollableTabScrollView setShowsHorizontalScrollIndicator:NO];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  //Prepare Vertical and horizontal scroll view
  scrollTabItemWidth = scrollableTabScrollView.frame.size.width/3;
  [self prepareScrollbleTabView];
  [self prepareVerticalScrollView];
}

/**
 *  This method is used to prepare the scrollable Tab View
 */
- (void)prepareScrollbleTabView {
  
  CGFloat buttonHeight  = scrollableTabScrollView.frame.size.height-20;
  
  for (int iCount=0; iCount<kMAXCOUNT; iCount++) {
    if (iCount == 0) {
      UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(iCount*scrollTabItemWidth, 20, scrollTabItemWidth, buttonHeight)];
      [dummyView setBackgroundColor:[colorArr objectAtIndex:iCount]];
      [scrollableTabScrollView addSubview:dummyView];
    } else {
      UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [tabButton setFrame:CGRectMake(iCount*scrollTabItemWidth, 20, scrollTabItemWidth, buttonHeight)];
      [tabButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
      [tabButton setBackgroundColor:[colorArr objectAtIndex:iCount]];
      [tabButton setTitle:[NSString stringWithFormat:@"Tab %d", iCount] forState:UIControlStateNormal];
      [tabButton setTag:iCount];
      [tabButton addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
      
      [scrollableTabScrollView addSubview:tabButton];
    }
  }
  [scrollableTabScrollView setContentSize:CGSizeMake(scrollTabItemWidth*(kMAXCOUNT+1), scrollableTabScrollView.frame.size.height)];
  [self addScrollableTabActiveBottomView:1];
}

/**
 *  Action for the tab button
 *
 *  @param sender
 */
- (IBAction)tabButtonPressed:(id)sender {

  UIButton *tabButton = (UIButton *)sender;
  CGFloat xPos = (tabButton.tag-1) * scrollTabItemWidth;
  
  CGRect vRect = verticalScrollView.bounds;
  vRect.origin = CGPointMake((tabButton.tag)*verticalScrollView.frame.size.width, verticalScrollView.bounds.origin.y);
  
  CGRect hRect = scrollableTabScrollView.bounds;
  hRect.origin = CGPointMake(xPos, scrollableTabScrollView.bounds.origin.y);
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.5f];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [scrollableTabScrollView setTransform:CGAffineTransformIdentity];
  [scrollableTabScrollView setBounds:hRect];
  [verticalScrollView setTransform:CGAffineTransformIdentity];
  [verticalScrollView setBounds:vRect];
  [UIView commitAnimations];
}

/**
 *  This method is used to add the scrollable tab view
 *
 *  @param activeIndex <#activeIndex description#>
 */
- (void)addScrollableTabActiveBottomView:(int)activeIndex {
  if (activeIndex == 0) {
    activeIndex = 1;
    [scrollableTabScrollView setContentOffset:CGPointMake(-scrollTabItemWidth, scrollableTabScrollView.contentOffset.y) animated:YES];
  }
  UIView *activeStripeView = [[UIView alloc] initWithFrame:CGRectMake(activeIndex*scrollTabItemWidth, scrollableTabScrollView.frame.size.height-10, scrollTabItemWidth, 10)];
  [activeStripeView setBackgroundColor:[UIColor blackColor]];
  [self.view addSubview:activeStripeView];
}

/**
 *  This method is used to prepeare the vertical scroll view
 */
- (void)prepareVerticalScrollView {
  
  for (int iCount=0; iCount<kMAXCOUNT; iCount++) {
    
    UIView *verticalView = [[UIView alloc] initWithFrame:CGRectMake(iCount*verticalScrollView.frame.size.width, 0, verticalScrollView.frame.size.width, verticalScrollView.frame.size.height)];
    [verticalView setBackgroundColor:[colorArr objectAtIndex:iCount]];
    [verticalScrollView addSubview:verticalView];
  }
  [verticalScrollView setContentSize:CGSizeMake(verticalScrollView.frame.size.width*kMAXCOUNT, verticalScrollView.frame.size.height)];
  [verticalScrollView setContentOffset:CGPointMake(verticalScrollView.frame.size.width, verticalScrollView.contentOffset.y) animated:YES];
}

#pragma ScrollView Delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  
  if (scrollView == scrollableTabScrollView) {
    CGFloat targetX = scrollView.contentOffset.x + velocity.x * 150.0;
    CGFloat targetIndex = round(targetX / scrollTabItemWidth);
    if (targetIndex < 0)
      targetIndex = 0;
    if (targetIndex > kMAXCOUNT)
      targetIndex = kMAXCOUNT;
    
    if (targetIndex!=0) {
      targetContentOffset->x = targetIndex * scrollTabItemWidth;
      [self heighlightCurrentItem:targetIndex+1];
    } else {
      [verticalScrollView setContentOffset:CGPointMake(verticalScrollView.frame.size.width, verticalScrollView.contentOffset.y) animated:YES];
    }
  } else if (scrollView == verticalScrollView) {
    CGFloat targetX = scrollView.contentOffset.x + velocity.x * 150.0;
    CGFloat targetIndex = round(targetX / verticalScrollView.frame.size.width);
    if (targetIndex < 0)
      targetIndex = 0;
    if (targetIndex > kMAXCOUNT)
      targetIndex = kMAXCOUNT;
    
    if (targetIndex!=0) {
      targetContentOffset->x = targetIndex * verticalScrollView.frame.size.width;
      [self heighlightCurrentItem:targetIndex];
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        [verticalScrollView setContentOffset:CGPointMake(verticalScrollView.frame.size.width, verticalScrollView.contentOffset.y) animated:YES];
      });
    }
  }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  if (scrollView == verticalScrollView) {
    
    CGFloat targetIndex = round(scrollView.contentOffset.x / verticalScrollView.frame.size.width);
    if (targetIndex != 0 && scrollView.contentOffset.x >= verticalScrollView.frame.size.width) {
      CGRect rect = scrollableTabScrollView.bounds;
      rect.origin = CGPointMake((scrollView.contentOffset.x/3)-scrollTabItemWidth, scrollableTabScrollView.bounds.origin.y);
      [scrollableTabScrollView setBounds:rect];
    }
  } else if (scrollView == scrollableTabScrollView) {
    
    CGRect rect = verticalScrollView.bounds;
    rect.origin = CGPointMake((scrollView.contentOffset.x*3)+verticalScrollView.frame.size.width, verticalScrollView.bounds.origin.y);
    [verticalScrollView setBounds:rect];
  }
}

/**
 *  This nethod is used to heighlight the current item
 *
 *  @param currentIndex
 */
- (void)heighlightCurrentItem:(CGFloat)currentIndex {
  for (int iCount=0; iCount<kMAXCOUNT; iCount++) {
    id button;
    if (currentIndex != iCount) {
      button = [scrollableTabScrollView viewWithTag:iCount];
      if ([button isKindOfClass:[UIButton class]]) {
        UIButton *tabButton = (UIButton *)button;
        [tabButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-UltraLight" size:18.0f]];
      }
    } else {
      button = (UIButton *)[scrollableTabScrollView viewWithTag:iCount];
      if ([button isKindOfClass:[UIButton class]]) {
        UIButton *tabButton = (UIButton *)button;
        [tabButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:18.0f]];
      }
    }
  }
}

/**
 *  This method is used to prepare the random color object
 *
 *  @return UIColor
 */
- (UIColor *)prepareRandomColor {
  NSInteger aRedValue = arc4random()%255;
  NSInteger aGreenValue = arc4random()%255;
  NSInteger aBlueValue = arc4random()%255;
  
  return [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
}

@end
