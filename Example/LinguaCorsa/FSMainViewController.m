//
//  FSMainViewController.m
//  LinguaCorsa
//
//  Created by Francescu SANTONI on 16/03/2014.
//  Copyright (c) 2014 Francescu. All rights reserved.
//

#import "FSMainViewController.h"
#import "GPUImage.h"

#import "FSRequestManager.h"
#import "FSRequest.h"
#import "Masonry.h"
#import "FSStateManager.h"
#import <EXTScope.h>

@interface FSMainViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (strong, nonatomic) FSStateManager *stateManager;
@end

@implementation FSMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    NSDictionary *attributes = @{NSFontAttributeName: self.textfield.font,
                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:1.f alpha:0.3f]};
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:self.textfield.placeholder attributes:attributes];
    self.textfield.attributedPlaceholder = placeholder;
    
    [self.textfield becomeFirstResponder];

    @weakify(self)
    NSDictionary *setup =
    
    @{@"main" :
          @{enterFunction:^{
              @strongify(self)
              [self cleanLayoutConstraints];
              
              [self.textfield makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(@(200));
                  make.left.equalTo(self.textfield.superview).with.offset(10);
                  make.right.equalTo(self.textfield.superview).with.offset(-10);
              }];
              
              [self.headerLabel makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(@(80));
                  make.left.equalTo(self.textfield.superview);
                  make.right.equalTo(self.textfield.superview);
              }];
              
              [self.view layoutIfNeeded];
          }},
      
      @"results"  :
          @{enterFunction:^{
              @strongify(self)
              [self cleanLayoutConstraints];
              
              [self.headerLabel makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(@(10));
                  make.left.equalTo(self.textfield.superview);
                  make.right.equalTo(self.textfield.superview).multipliedBy(0.5);
              }];
              
              [self.textfield makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(self.headerLabel.bottom).with.offset(10);
                  make.left.equalTo(self.textfield.superview).with.offset(10);
                  make.right.equalTo(self.textfield.superview).with.offset(-10);
              }];
              [self.view layoutIfNeeded];
          }},
      @"loading"  :
          @{enterFunction:^{
              @strongify(self)
              [self.loadingView startAnimating];
          },
            exitFunction:^{
                @strongify(self)
                [self.loadingView stopAnimating];
            }}
      };
    
    
    self.stateManager = FSStateManager.new.setup(setup);
    self.stateManager.transitionTo(@"main");
    
}

- (void)cleanLayoutConstraints
{
    [self.view removeConstraints:self.view.constraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (FSRequest *)requestFromCurrentScreenState
{
    FSRequest *request = [[FSRequest alloc] init];
    request.searchMode = FSRequestSearchOptionContains;
    request.searchLanguage = FSRequestLanguageFrench;
    request.request = self.textfield.text;
    
    return request;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    FSRequest *request = [self requestFromCurrentScreenState];
    FSRequestManager *manager = [[FSRequestManager alloc] initWithRequest:request];
    
    self.stateManager.transitionTo(@"loading");
    
    [manager startRequestWithCompletion:^(FSResult *result, NSError *error) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.stateManager.transitionTo(@"results");
        } completion:^(BOOL finished) {
            [self.textfield resignFirstResponder];
        }];
    }];
    
    return YES;
}

@end
