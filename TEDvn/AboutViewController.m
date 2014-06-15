//
//  AboutViewController.m
//  TEDvn
//
//  Created by samthui7 on 5/10/14.
//  Copyright (c) 2014 samthui7. All rights reserved.
//

#import "AboutViewController.h"

#define ENG_ABOUT @" TEDvn is a non-profit fansub project to translate all the inspiring TED Talks into Vietnamese. So that Vietnamese, those who aren’t good in English, can view and get inspired by great leaders of the world. We hope they can make some changes form those wonderful ideas, for themselves, for their communities, and who know, for the whole world.\n This sharing project abides by Creative Commons license belong to TED.\n If you want to be with us, don’t hesitate to contact us now: mrkentran@TEDvn.com\n Your support will always be helpful!\n Best wishes for you,\n Ken Tran."
#define VIET_ABOUT @" TEDvn là một dự án fansub phi lợi nhuận, nhằm dịch toàn bộ những bài diễn thuyết truyền cảm hứng từ TED Talks sang tiếng Việt. Qua đó, người Việt Nam, đặc biệt là những người chưa giỏi tiếng Anh, có thể xem và được truyền cảm hứng bởi những lãnh đạo vĩ đại của thế giới. Chúng tôi hy vọng họ sẽ tạo được những thay đổi từ các ý tưởng tuyệt vời này, cho chính họ, cho cộng đồng của họ, và biết đâu, cho cả thế giới.\n Dự án chia sẻ này tuân theo bản quyền chia sẻ Creative Commons của TED.\n Nếu bạn muốn hỗ trợ chúng tôi, đừng ngần ngại, hãy liên lạc ngay: mrkentran@TEDvn.com\n Sự hỗ trợ của bạn sẽ luôn luôn hữu ích.\n Chân thành cảm ơn,\n Ken Tran."

@interface AboutViewController ()

@end

@implementation AboutViewController

@synthesize aboutTextView;
@synthesize languageSegment;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)languageDidChange:(id)sender
{
    if (self.languageSegment.selectedSegmentIndex == 0) {
        //Việt
        [self.aboutTextView setText:VIET_ABOUT];
    }else{
        //Eng
        [self.aboutTextView setText:ENG_ABOUT];
    }
}

@end
