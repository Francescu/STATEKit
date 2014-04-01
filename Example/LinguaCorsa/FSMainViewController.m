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
#import "FSResult.h"
#import "FSWordDefinition.h"

#import "Masonry.h"
#import "YOLO.h"
#import "FSStateManager.h"
#import <EXTScope.h>

UNSTRING(searchState)
UNSTRING(typingState)
UNSTRING(loadingState)
UNSTRING(resultsState)
UNSTRING(transitioningState)

UNSTRING(search)
UNSTRING(back)
UNSTRING(filterTyping)

@interface FSMainViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *resultsView;

@property (strong, nonatomic) FSStateManager *stateManager;
@property (strong, nonatomic) NSArray *words;
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
    
    @{
      searchState :
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
              
              [self.headerLabel setNeedsDisplay];
              [self.view layoutIfNeeded];
              self.stateManager.listen(self.textfield).forwardToTransition(textfieldWillEdit, STkPath(searchState, typingState));
          },
            exitFunction:^{

            },
            typingState: @{
                    enterFunction:^{
                        @strongify(self)
                        self.stateManager.listen(self.textfield).forward(textfieldWillChangeText, filterTyping);
                        self.stateManager.listen(self.textfield).forward(textfieldWillReturn, search);
                    },
                    exitFunction:^{
                        @strongify(self)
                        self.stateManager.listen(self.textfield).unforward(textfieldWillChangeText);
                        self.stateManager.listen(self.textfield).unforward(textfieldWillReturn);
                    },
                    filterTyping:^{
                        @strongify(self)
                        NSDictionary *params = self.textfield.last(textfieldWillChangeText);
                        if (params)
                        {
                            NSString *text = params[kSTkTextFieldParamsKeyReplacementString];
                            if (text)
                            {
                                NSCharacterSet *set = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
                                NSRange r = [text rangeOfCharacterFromSet:set options:NSCaseInsensitiveSearch];
                                return (BOOL)(r.location == NSNotFound);
                            }
                        }
                        return NO;
                    },
                    search:^{
                        @strongify(self)
                        
                        FSRequest *request = [self requestFromCurrentScreenState];
                        FSRequestManager *manager = [[FSRequestManager alloc] initWithRequest:request];
                        
                        self.stateManager.transitionTo(STkPath(searchState,loadingState));
                        
                        [manager startRequestWithCompletion:^(FSResult *result, NSError *error) {
                            self.words = result.words;
                            
                            [UIView animateWithDuration:0.5 animations:^{
                                self.stateManager.transitionTo(resultsState);
                            }];
                        }];
                        
                        return YES;
                    }
                    },
            loadingState: @{
                    enterFunction:^{
                        @strongify(self)
                        [self.loadingView startAnimating];
                        self.stateManager.listen(self.textfield).forward(textfieldWillChangeText, filterTyping);
                    },
                    exitFunction:^{
                        @strongify(self)
                        [self.loadingView stopAnimating];
                        self.stateManager.listen(self.textfield).unforward(textfieldWillChangeText);
                    },
                    filterTyping:^{
                        return NO;
                    }}
            
            },
      /************** RESULTS STATE ***************/
      resultsState:
          @{enterFunction:^{
              @strongify(self)
              [self cleanLayoutConstraints];
              [self.resultsView removeConstraints:self.resultsView.constraints];
              
              [self.headerLabel makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(self.view.top).offset(10);
                  make.left.equalTo(self.textfield.superview).with.offset(10);
                  make.right.equalTo(self.textfield.superview).with.offset(-10);
              }];
              
              [self.textfield makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(self.headerLabel.bottom).with.offset(10);
                  make.left.equalTo(self.textfield.superview).with.offset(10);
                  make.right.equalTo(self.textfield.superview).with.offset(-10);
              }];
              
              [self.resultsView makeConstraints:^(MASConstraintMaker *make) {
                  make.top.equalTo(self.textfield.mas_bottom);
                  make.left.equalTo(self.resultsView.superview);
                  make.right.equalTo(self.resultsView.superview.right);
                  make.width.equalTo(self.resultsView.superview.width);
              }];
              
              self.resultsView.subviews.each(^(UIView *v){[v removeFromSuperview];});
              
              self.resultsView.alpha = 1;
              
              UIView *lastView = nil;
              
              for (FSWordDefinition *word in self.words.first(10))
              {
                  UILabel *title = [[UILabel alloc] init];
                  [title setText:word.word];
                  [title setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:21]];
                  [title setTextColor:[UIColor whiteColor]];
                  [self.resultsView addSubview:title];
                  
                  [title makeConstraints:^(MASConstraintMaker *make) {
                      if (lastView)
                      {
                          make.top.equalTo(lastView.bottom).offset(10);
                      }
                      else
                      {
                          make.top.equalTo(title.superview.top);
                      }
                      make.left.equalTo(title.superview.left).offset(20);
                      make.right.equalTo(title.superview.right).offset(-10).priority(999);
                  }];
                  
                  UILabel *subtitle = [[UILabel alloc] init];
                  [subtitle setText:word.translation];
                  [subtitle setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
                  [subtitle setTextColor:[UIColor colorWithWhite:0.98f alpha:1.f]];
                  
                  [self.resultsView addSubview:subtitle];
                  
                  [subtitle makeConstraints:^(MASConstraintMaker *make) {
                      make.top.equalTo(title.bottom);
                      make.left.equalTo(subtitle.superview.left).offset(30);
                      make.right.equalTo(subtitle.superview.right).offset(-10).priority(999);
                  }];
                  lastView = subtitle;

              }
              
              [lastView makeConstraints:^(MASConstraintMaker *make) {
                  make.bottom.equalTo(lastView.superview.mas_bottom);
              }];
              
              [self.view layoutIfNeeded];
              [self.textfield resignFirstResponder];
              
              self.stateManager.listen(self.textfield).forwardToTransition(textfieldWillEdit,STkPath(searchState,typingState));
          },
            exitFunction:^{
                @strongify(self)
                self.stateManager.mute(self.textfield);
                [UIView animateWithDuration:0.3 animations:^{
                    self.resultsView.alpha = 0;
                }];

            },
            }
      };
    
    self.stateManager = FSStateManager.new.setup(setup);
    self.stateManager.transitionTo(searchState);
    
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}
- (void)cleanLayoutConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    [self.scrollView removeConstraints:self.scrollView.constraints];
    
    [self.scrollView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView.superview);
    }];
    
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
    request.searchMode = FSRequestSearchOptionEqualsTo;
    request.searchLanguage = FSRequestLanguageFrench;
    request.request = self.textfield.text;
    
    return request;
}


@end
